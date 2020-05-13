%%
clear

%%
load('gTruthCellMoving.mat')
%load('gTruth.mat')

%%
A = GTruthConverter(gTruth);
% B = SeparateLabelDef(gTruth);

%%
% セグメント

imshow(A.getSegmentFusionImage(1,1))

%% 動画を４Dに読み込み
% メモリ問題で失敗
% movie4d = ReadMovie2Memory('cellMoving.avi');

%% Rect 
frame = 1;
rectId = 1;
A.viewRectImage(frame, rectId)

%% 複数のRectを画像に埋め込む
frame = 1;
I = A.getMultipleRectImage(frame, [1 2]);
imshow(I)

%% RectCenterLine
frame = 1;
rectId = 1;
A.viewRectCenterLine(frame, rectId);

%% numOfFrame の実験１
numOfFrame = 50;
A.viewRectCenterLine(frame, rectId, numOfFrame);

%% numOfFrame の実験２
frame = 50;
A.viewRectCenterLine(frame, rectId, frame);

%% 複数の RectCenterLine１
frame = 1;
rectIdList = [1 2];
I = A.getMultipleRectCenterLineImage(frame, rectIdList);
imshow(I)

%% 複数の RectCenterLine２
frame = 50;
rectIdList = [1 2];
I = A.getMultipleRectCenterLineImage(frame, rectIdList, frame);
I = A.getMultipleRect2Image(frame, rectIdList, I);
imshow(I)

%% 複数の RectCenterLine３
% ToDo: frame = 100 の時だけ画像がおかしくなる　Iを二回評価している？
frame = 100;
rectIdList = [1 2];
I = A.getMultipleRectAndCenterLine(frame, rectIdList, frame);
imshow(I)

%% 移動速度のplot 全体
rectId = 1;
list = A.getRectCenterDeltaList(rectId);
plot(list)

%% 移動速度のplot２
rectId = 1;
frame = 50;
list = A.getRectCenterDeltaList(rectId, frame);
plot(list)

%%
%
list = A.getRectCenterDeltaList(rectId);
xlimVal = [0,size(list,2)];
ylimVal = [0,max(list,[],'all')*1.1]; % 最大よりも10%上

%
outputFolder = 'outFolder';
mkdir(outputFolder);

h = figure('Units','normalized','Position',[0.05 0.05 0.9 0.5],'Visible','on');
rectIdList = [1 2];

% ToDo frame = 100の時だけおかしい なぜ？
for frame =1 : A.numOfImages;
    subplot(1,2,1)
    I = A.getMultipleRectAndCenterLine(frame, rectIdList, frame);
    imshow(I)

    subplot(1,2,2)
    plot(list(1:frame))
    xlim(xlimVal);
    ylim(ylimVal);

    outFileName =fullfile(outputFolder,sprintf('%04d.png',frame));
    saveas(gcf, outFileName);
end

%% 動画に変換
% ToDo: i=100 の時にだけ画像が変になる

% ビデオ書き込み設定
outputMovieFolder = 'outMovie';
mkdir(outputMovieFolder);
imgStore = imageDatastore(outputFolder);

% ビデオ書き込み
outputVideo = VideoWriter(fullfile(outputMovieFolder,'test.avi'));
%outputVideo.FrameRate = shuttleVideo.FrameRate;
open(outputVideo)

for i = 1:length(imgStore.Files)
   writeVideo(outputVideo, readimage(imgStore,i));
end
close(outputVideo)

