imageNames = dir(fullfile('*.png'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter('scheduler.mp4', 'MPEG-4');
outputVideo.FrameRate = 30;
outputVideo.Quality = 100
open(outputVideo)

for ii = 1:length(imageNames)
   img = imread(imageNames{ii});
   img = imresize(img, [1080 1920]);
   writeVideo(outputVideo, img);
end

close(outputVideo);
