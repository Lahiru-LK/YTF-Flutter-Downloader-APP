import 'package:youtube_explode_dart/youtube_explode_dart.dart';


class VideoDownloadService {
  static Future<Map<String, String>> fetchYouTubeDetails(String url) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(url);
      final manifest = await yt.videos.streamsClient.getManifest(video.id);

      // Try muxed first
      if (manifest.muxed.isNotEmpty) {
        final streamInfo = manifest.muxed.withHighestBitrate();
        final sizeInMB = streamInfo.size.totalMegaBytes.toStringAsFixed(2);
        return {
          'title': video.title,
          'thumbnail': video.thumbnails.highResUrl,
          'size': '$sizeInMB MB',
        };
      }

      // Fallback to video-only + audio-only
      final videoStream = manifest.videoOnly.withHighestBitrate();
      final audioStream = manifest.audioOnly.withHighestBitrate();
      final combinedSize = videoStream.size.totalMegaBytes + audioStream.size.totalMegaBytes;

      return {
        'title': video.title,
        'thumbnail': video.thumbnails.highResUrl,
        'size': '${combinedSize.toStringAsFixed(2)} MB (Video+Audio)',
      };
    } catch (e) {
      print("❌ Error fetching video details: $e");
      rethrow;
    } finally {
      yt.close();
    }
  }


  static Future<String> getVideoUrlByQuality(String url, String qualityLabel) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(url);
      final manifest = await yt.videos.streamsClient.getManifest(video.id);
      final stream = manifest.muxed.firstWhere(
            (s) => s.qualityLabel == qualityLabel,
        orElse: () => throw Exception('Quality not available'),
      );

      if (stream != null) {
        return stream.url.toString();
      } else {
        throw Exception('Quality not available');
      }
    } finally {
      yt.close();
    }
  }
}
