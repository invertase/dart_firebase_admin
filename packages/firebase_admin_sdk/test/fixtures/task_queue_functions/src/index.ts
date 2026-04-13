import { onTaskDispatched } from "firebase-functions/v2/tasks";

export const helloWorld = onTaskDispatched(
  {
    retryConfig: {
      maxAttempts: 5,
      minBackoffSeconds: 60,
    },
    rateLimits: {
      maxConcurrentDispatches: 6,
    },
  },
  async (req) => {
    console.log("Task received:", req.data);
  }
);
