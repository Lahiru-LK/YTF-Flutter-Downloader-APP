import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:collection/collection.dart';


class VideoDownloadService {
  static Future<List<Map<String, String>>> getAvailableQualities(String url) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(url);
      final manifest = await yt.videos.streamsClient.getManifest(video.id);

      final List<Map<String, String>> results = [];

      // ✅ List of desired qualities
      final List<String> desiredQualities = ['360p', '480p', '720p', '1080p', '1440p', '2160p'];

      for (var quality in desiredQualities) {
        // ✅ Try muxed stream first (video+audio in one)
        final muxed = manifest.muxed.firstWhereOrNull(
              (s) => s.qualityLabel == quality,
        );

        if (muxed != null) {
          results.add({
            'label': quality,
            'size': '${muxed.size.totalMegaBytes.toStringAsFixed(2)} MB',
            'url': muxed.url.toString(),
          });
        } else {
          // ✅ Fallback to videoOnly + audioOnly merge
          final videoOnly = manifest.videoOnly.firstWhereOrNull(
                (v) => v.qualityLabel == quality,
          );
          final audio = manifest.audioOnly.withHighestBitrate();

          if (videoOnly != null && audio != null) {
            final size = videoOnly.size.totalMegaBytes + audio.size.totalMegaBytes;

            results.add({
              'label': '$quality (Video+Audio)',
              'size': '${size.toStringAsFixed(2)} MB',
              'url': videoOnly.url.toString(), // Still separate (needs merging)
            });
          }
        }
      }

      return results;
    } catch (e) {
      print('❌ Error getting qualities: $e');
      return [];
    } finally {
      yt.close();
    }
  }




  static Future<Map<String, String>> fetchYouTubeDetails(String url) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(url);
      final manifest = await yt.videos.streamsClient.getManifest(video.id);

      if (manifest.muxed.isNotEmpty) {
        final streamInfo = manifest.muxed.withHighestBitrate();
        final sizeInMB = streamInfo.size.totalMegaBytes.toStringAsFixed(2);

        return {
          'title': video.title,
          'thumbnail': video.thumbnails.highResUrl,
          'size': '$sizeInMB MB',
        };
      }

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
}
