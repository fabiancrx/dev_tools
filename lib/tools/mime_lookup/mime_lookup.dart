class MimeEntry {
  final String extension;
  final String mimeType;

  const MimeEntry(this.extension, this.mimeType);

  String get category => mimeType.split('/').first;

  bool matches(String q) =>
      extension.contains(q) || mimeType.contains(q);
}

const List<MimeEntry> mimeEntries = [
  // Text
  MimeEntry('html', 'text/html'),
  MimeEntry('htm', 'text/html'),
  MimeEntry('css', 'text/css'),
  MimeEntry('js', 'text/javascript'),
  MimeEntry('mjs', 'text/javascript'),
  MimeEntry('txt', 'text/plain'),
  MimeEntry('md', 'text/markdown'),
  MimeEntry('markdown', 'text/markdown'),
  MimeEntry('csv', 'text/csv'),
  MimeEntry('tsv', 'text/tab-separated-values'),
  MimeEntry('rtf', 'text/rtf'),
  MimeEntry('yaml', 'text/yaml'),
  MimeEntry('yml', 'text/yaml'),
  MimeEntry('ics', 'text/calendar'),
  MimeEntry('vcf', 'text/vcard'),
  MimeEntry('vcard', 'text/vcard'),
  MimeEntry('sgml', 'text/sgml'),
  MimeEntry('textile', 'text/x-textile'),

  // Image
  MimeEntry('png', 'image/png'),
  MimeEntry('jpg', 'image/jpeg'),
  MimeEntry('jpeg', 'image/jpeg'),
  MimeEntry('gif', 'image/gif'),
  MimeEntry('webp', 'image/webp'),
  MimeEntry('avif', 'image/avif'),
  MimeEntry('svg', 'image/svg+xml'),
  MimeEntry('ico', 'image/x-icon'),
  MimeEntry('bmp', 'image/bmp'),
  MimeEntry('tiff', 'image/tiff'),
  MimeEntry('tif', 'image/tiff'),
  MimeEntry('heic', 'image/heic'),
  MimeEntry('heif', 'image/heif'),
  MimeEntry('jxl', 'image/jxl'),
  MimeEntry('apng', 'image/apng'),

  // Audio
  MimeEntry('mp3', 'audio/mpeg'),
  MimeEntry('wav', 'audio/wav'),
  MimeEntry('ogg', 'audio/ogg'),
  MimeEntry('flac', 'audio/flac'),
  MimeEntry('m4a', 'audio/mp4'),
  MimeEntry('aac', 'audio/aac'),
  MimeEntry('opus', 'audio/opus'),
  MimeEntry('mid', 'audio/midi'),
  MimeEntry('midi', 'audio/midi'),
  MimeEntry('weba', 'audio/webm'),
  MimeEntry('aiff', 'audio/aiff'),

  // Video
  MimeEntry('mp4', 'video/mp4'),
  MimeEntry('webm', 'video/webm'),
  MimeEntry('avi', 'video/x-msvideo'),
  MimeEntry('mkv', 'video/x-matroska'),
  MimeEntry('mov', 'video/quicktime'),
  MimeEntry('ogv', 'video/ogg'),
  MimeEntry('m4v', 'video/mp4'),
  MimeEntry('mpeg', 'video/mpeg'),
  MimeEntry('mpg', 'video/mpeg'),
  MimeEntry('ts', 'video/mp2t'),
  MimeEntry('3gp', 'video/3gpp'),
  MimeEntry('flv', 'video/x-flv'),

  // Application
  MimeEntry('json', 'application/json'),
  MimeEntry('jsonld', 'application/ld+json'),
  MimeEntry('pdf', 'application/pdf'),
  MimeEntry('wasm', 'application/wasm'),
  MimeEntry('xml', 'application/xml'),
  MimeEntry('xhtml', 'application/xhtml+xml'),
  MimeEntry('rss', 'application/rss+xml'),
  MimeEntry('atom', 'application/atom+xml'),
  MimeEntry('bin', 'application/octet-stream'),
  MimeEntry('exe', 'application/octet-stream'),
  MimeEntry('apk', 'application/vnd.android.package-archive'),
  MimeEntry('jar', 'application/java-archive'),
  MimeEntry('sql', 'application/sql'),
  MimeEntry('graphql', 'application/graphql'),
  MimeEntry('proto', 'application/protobuf'),
  MimeEntry('cbor', 'application/cbor'),
  MimeEntry('msgpack', 'application/msgpack'),
  MimeEntry('woff', 'font/woff'),
  MimeEntry('woff2', 'font/woff2'),
  MimeEntry('ttf', 'font/ttf'),
  MimeEntry('otf', 'font/otf'),
  MimeEntry('eot', 'application/vnd.ms-fontobject'),

  // Archives
  MimeEntry('zip', 'application/zip'),
  MimeEntry('gz', 'application/gzip'),
  MimeEntry('tar', 'application/x-tar'),
  MimeEntry('bz2', 'application/x-bzip2'),
  MimeEntry('7z', 'application/x-7z-compressed'),
  MimeEntry('rar', 'application/vnd.rar'),
  MimeEntry('xz', 'application/x-xz'),
  MimeEntry('zst', 'application/zstd'),
  MimeEntry('br', 'application/x-brotli'),

  // Documents
  MimeEntry('doc', 'application/msword'),
  MimeEntry('docx', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'),
  MimeEntry('xls', 'application/vnd.ms-excel'),
  MimeEntry('xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
  MimeEntry('ppt', 'application/vnd.ms-powerpoint'),
  MimeEntry('pptx', 'application/vnd.openxmlformats-officedocument.presentationml.presentation'),
  MimeEntry('odt', 'application/vnd.oasis.opendocument.text'),
  MimeEntry('ods', 'application/vnd.oasis.opendocument.spreadsheet'),
  MimeEntry('odp', 'application/vnd.oasis.opendocument.presentation'),
  MimeEntry('epub', 'application/epub+zip'),

  // Multipart / form
  MimeEntry('multipart/form-data', 'multipart/form-data'),
  MimeEntry('multipart/mixed', 'multipart/mixed'),

  // Font (standalone entries so they appear under "font" category)
];
