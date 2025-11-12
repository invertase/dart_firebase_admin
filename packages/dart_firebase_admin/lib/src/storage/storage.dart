part of '../storage.dart';

class Storage extends _BaseStorage {
  Storage(FirebaseAdminApp app) : super(app: app);

  @override
  Bucket bucket([String? name]) {
    // TODO this.appInternal.options.storageBucket;
    final bucketName = name ?? 'TODO';
    if (bucketName.isEmpty) {
      throw UnimplementedError('TODO');
      //   TODO    throw new FirebaseError({
      //   code: 'storage/invalid-argument',
      //   message: 'Bucket name not specified or invalid. Specify a valid bucket name via the ' +
      //             'storageBucket option when initializing the app, or specify the bucket name ' +
      //             'explicitly when calling the getBucket() method.',
      // });
    }

    return Bucket._(
      name: bucketName,
      storage: this,
      options: BucketOptions(),
    );
  }
}
