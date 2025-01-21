import 'package:video_thumbnail/video_thumbnail.dart'; 
import 'package:path_provider/path_provider.dart'; 

// 비디오 썸네일 생성 함수
Future<String> generateThumbnail(String videoUrl) async {
  try {
    final tempDir = await getTemporaryDirectory(); // 임시 디렉토리 경로 가져오기
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoUrl, // 비디오 URL
      thumbnailPath: tempDir.path, // 썸네일 저장 경로
      imageFormat: ImageFormat.PNG, 
      quality: 75, // 썸네일 품질
    );
    return thumbnailPath!; // 생성된 썸네일 경로 반환
  } catch (e) {
    print('Thumbnail generation error: $e'); // 에러 로그 출력
    return ''; // 실패 시 빈 문자열 반환
  }
}
