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

      String title = video.title;
      String thumbnail = video.thumbnails.highResUrl;
      String size = 'Unknown';

      if (manifest.muxed.isNotEmpty) {
        final stream = manifest.muxed.withHighestBitrate();
        size = '${stream.size.totalMegaBytes.toStringAsFixed(2)} MB';
      } else {
        final videoStream = manifest.videoOnly.firstWhereOrNull((e) => true);
        final audioStream = manifest.audioOnly.firstWhereOrNull((e) => true);

        if (videoStream != null && audioStream != null) {
          final combinedSize = videoStream.size.totalMegaBytes + audioStream.size.totalMegaBytes;
          size = '${combinedSize.toStringAsFixed(2)} MB (Video+Audio)';
        }
      }

      return {
        'title': title,
        'thumbnail': thumbnail,
        'size': size,
      };
    } catch (e) {
      print("❌ Error fetching video details: $e");
      return {};
    } finally {
      yt.close();
    }
  }




}
