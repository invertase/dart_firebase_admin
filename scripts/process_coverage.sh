#!/bin/bash
set -e

# 1. Merge coverage reports
# Save individual package coverage files before merging
cp coverage.lcov coverage_admin.lcov
cp ../google_cloud_firestore/coverage.lcov coverage_firestore.lcov

# Merge coverage reports from all packages (relative to packages/firebase_admin_sdk)
# Only merge files that exist
COVERAGE_FILES=""
[ -f coverage.lcov ] && COVERAGE_FILES="$COVERAGE_FILES coverage.lcov"
[ -f ../google_cloud_firestore/coverage.lcov ] && COVERAGE_FILES="$COVERAGE_FILES ../google_cloud_firestore/coverage.lcov"

if [ -n "$COVERAGE_FILES" ]; then
  cat $COVERAGE_FILES > merged_coverage.lcov
  mv merged_coverage.lcov coverage.lcov
else
  echo "No coverage files found!"
  exit 1
fi

# 2. Calculate coverage and check threshold
calculate_coverage() {
  local file=$1
  if [ -f "$file" ]; then
    local total=$(grep -E "^LF:" "$file" | awk -F: '{sum+=$2} END {print sum}')
    local hit=$(grep -E "^LH:" "$file" | awk -F: '{sum+=$2} END {print sum}')
    if [ "$total" -gt 0 ]; then
      local pct=$(awk "BEGIN {printf \"%.2f\", ($hit/$total)*100}")
      echo "$pct|$hit|$total"
    else
      echo "0.00|0|0"
    fi
  else
    echo "0.00|0|0"
  fi
}

# Get individual package coverage from saved copies
ADMIN_COV=$(calculate_coverage "coverage_admin.lcov")
FIRESTORE_COV=$(calculate_coverage "coverage_firestore.lcov")
STORAGE_COV=$(calculate_coverage "coverage_storage.lcov")

ADMIN_PCT=$(echo $ADMIN_COV | cut -d'|' -f1)
ADMIN_HIT=$(echo $ADMIN_COV | cut -d'|' -f2)
ADMIN_TOTAL=$(echo $ADMIN_COV | cut -d'|' -f3)

FIRESTORE_PCT=$(echo $FIRESTORE_COV | cut -d'|' -f1)
FIRESTORE_HIT=$(echo $FIRESTORE_COV | cut -d'|' -f2)
FIRESTORE_TOTAL=$(echo $FIRESTORE_COV | cut -d'|' -f3)

STORAGE_PCT=$(echo $STORAGE_COV | cut -d'|' -f1)
STORAGE_HIT=$(echo $STORAGE_COV | cut -d'|' -f2)
STORAGE_TOTAL=$(echo $STORAGE_COV | cut -d'|' -f3)

# Calculate total coverage from merged file
TOTAL_LINES=$(grep -E "^(DA|LF):" coverage.lcov | grep "^LF:" | awk -F: '{sum+=$2} END {print sum}')
HIT_LINES=$(grep -E "^(DA|LH):" coverage.lcov | grep "^LH:" | awk -F: '{sum+=$2} END {print sum}')

if [ "$TOTAL_LINES" -gt 0 ]; then
  COVERAGE_PCT=$(awk "BEGIN {printf \"%.2f\", ($HIT_LINES/$TOTAL_LINES)*100}")
else
  COVERAGE_PCT="0.00"
fi

# Output for GitHub Actions
echo "coverage=${COVERAGE_PCT}" >> $GITHUB_OUTPUT
echo "total_lines=${TOTAL_LINES}" >> $GITHUB_OUTPUT
echo "hit_lines=${HIT_LINES}" >> $GITHUB_OUTPUT

echo "admin_coverage=${ADMIN_PCT}" >> $GITHUB_OUTPUT
echo "firestore_coverage=${FIRESTORE_PCT}" >> $GITHUB_OUTPUT
echo "storage_coverage=${STORAGE_PCT}" >> $GITHUB_OUTPUT

# Console output
echo "=== Coverage Report ==="
echo "firebase_admin_sdk: ${ADMIN_PCT}% (${ADMIN_HIT}/${ADMIN_TOTAL} lines)"
echo "google_cloud_firestore: ${FIRESTORE_PCT}% (${FIRESTORE_HIT}/${FIRESTORE_TOTAL} lines)"
echo "----------------------"
echo "Total: ${COVERAGE_PCT}% (${HIT_LINES}/${TOTAL_LINES} lines)"

# Check threshold
if (( $(echo "$COVERAGE_PCT < 40" | bc -l) )); then
  echo "status=❌ Coverage ${COVERAGE_PCT}% is below 40% threshold" >> $GITHUB_OUTPUT
  exit 1
else
  echo "status=✅ Coverage ${COVERAGE_PCT}% meets 40% threshold" >> $GITHUB_OUTPUT
fi
