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

%% Rectの中身
rectId = 1;
A.viewAllRectSelectedImage(rectId)

%%

%% Rect内で細胞の中心を計算≒緑色領域の中心をとらえる
% 目的：　
% Step1 : rect内の画像を抽出
% Step2 : LAB変換で緑領域を抽出　regionpropsを用いて細胞の中心を取得

% 設定
frame = 100;
rectId = 1;

% % 
% Irect = A.getRectSelectedImage(frame ,rectId);
% Ilab = rgb2lab(Irect); % labに変換
% Ilab2 = Ilab(:,:,2); % labの2を取得（緑方向）
% Ilab2Index = (Ilab2<0); % 0未満のインデックスを取得
% imshow(Ilab2Index)
% 
% % regionprops を用いて分割
% s = regionprops(Ilab2Index);
% 
% % 最大面積のindexを取得
% %boundingBox = [s(1).BoundingBox ; s(2).BoundingBox];
% %Irect = insertShape(I, 'Rectangle', boundingBox, ...
% %    'LineWidth', 5, 'Color', 'red');
% %imshow(Irect);
% 
% 
% areaList = [s.Area]; % max関数で構造体を評価するとindexが得れないので配列に変換
% [~, index] = max(areaList);
% centroid = s(index).Centroid;
% boundingBox = [s(index).BoundingBox]; 
% 
% % position
% I = A.getOriginalImage(frame); % 元画像
% position = A.getRectPosition(frame,rectId);
% position = round(position); % BoundingBox演算はround後なので同様にround
% 
% % boundingBox : [x1, y1, x2, y2]
% % position : [x, y, l, h ]
% % centroid : [x, y]
% % insertshapeは position形式であるため変換が必要
% 
% position12 = [position(1), position(2)]; 
% centroidAtOriginal = position12 + centroid;
% boundingBoxAtOriginal = [position12 , 0 , 0 ] + boundingBox;

position = A.getRectGreenCellCenter(frame,rectId);

Irect = insertShape(I, 'Rectangle', boundingBoxAtOriginal, ...
    'LineWidth', 5, 'Color', 'red');
imshow(Irect);


%%

%% n=100 問題　→　解決（元の画像がまずかった）
frame = 100;
rectId = 1;
A.viewRectSelectedImage(frame ,rectId)

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

%% 二画面表示　左がRectとライン　右が速度のグラフ
% グラフを固定するためのxlim, xylimの計算
list = A.getRectCenterDeltaList(rectId);
xlimVal = [0,size(list,2)];
ylimVal = [0,max(list,[],'all')*1.1]; % 最大よりも10%上

% 基本設定
outputFolder = 'outFolder2GreenCell';
mkdir(outputFolder);

h = figure('Units','normalized','Position',[0.05 0.05 0.9 0.5],'Visible','on');
rectIdList = [1 2];

% 二画面表示
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

