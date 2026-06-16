String optimizeShowcaseImageUrl(String? rawUrl) {
  if (rawUrl == null) return '';

  var url = rawUrl.trim();
  if (url.isEmpty) return '';

  url = Uri.encodeFull(url);

  if (url.contains('image.tmdb.org') && url.contains('/original/')) {
    return url.replaceFirst('/original/', '/w500/');
  }

  return url;
}
