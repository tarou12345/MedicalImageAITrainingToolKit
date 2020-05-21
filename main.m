%%
clear
% 機能一覧＋テスト
% ToDo:

%% gTruth 読み込み
%load('gTruthCellMoving.mat')
load('gTruth.mat')

%%
A = GTruthConverter(gTruth);
% B = SeparateLabelDef(gTruth);

%%
A.disp()
%% 元画像　＋　単一セグメント　を表示
frame = 1;
labelId = 1;
A.viewSegmentFusionImage(frame,labelId)

%% 元画像　＋　複数セグメント　を表示
frame = 1;
segmentIdList = [1 2];
A.viewMultipleSegmentFusionImage(frame,segmentIdList);

%% 全セグメントをIDごとに色付けして表示
frame = 1;
A.viewSegmentIndexColorImage(frame)

%% 特定のセグメントを抽出して色付け
frame = 1;
segmentId = 1;
I = A.getSingleSegmentImageWithColor(frame, segmentId);
imshow(I)

%% 特定のセグメントを抽出して色付け表示
A.viewSingleSegmentImageWithColor(frame, segmentId)

%% segment 特定のsegmentId 画像を抽出
frame = 1;
segmentIdA = 1;
segmentIdB = 2;
I = A.getSingleSegmentImageWithColor(frame, segmentIdA);
I = A.insertSegmentImageWithColor(frame, segmentIdB, I);
imshow(I)

%% segment 特定のsegmentId 画像を抽出しラベルのテキストを挿入
frame = 1;
segmentId = 1;

I = A.getSinglSegmentImageWithColorAndSegmentName(frame, segmentId);
imshow(I)

%% segment 複数のsegmentId 画像を抽出しラベル名を挿入
frame = 1;
segmentIdA = 1;
segmentIdB = 2;

IA = A.getSinglSegmentImageWithColorAndSegmentName(frame, segmentIdA);
IB = A.getSinglSegmentImageWithColorAndSegmentName(frame, segmentIdB);
I = IA + IB;
imshow(I)

%% segment 複数のsegmentId 画像を抽出しラベル名を挿入
frame = 1;
segmentIdList = [1 2];
I = A.getMultiplelSegmentImageWithColorAndSegmentName(frame, segmentIdList);
imshow(I)

%% 複数のsegmentId のsegmentを画像に挿入してラベル名も挿入
frame = 1;
segmentIdList = [1 2];
I = A.getMultipleSegmentFusionImage(frame, segmentIdList);
I = A.insertMultipleSegmentLabelName(frame, segmentIdList, I);
imshow(I)

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
frame = 2;
rectId = 2;

I = A.getOriginalImage(frame);
[boundingBoxAtOriginal, centroidAtOriginal] = A.getRectGreenCellCenter(frame,rectId);

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

%% 

% rectId のリスト
rectIdList = [A.rect.labelId];

% frame=1 の時のみ
for i = 1:A.rectCount
    rectId = rectIdList(i);
    
    % postの初期化
    [~, centroidAtOriginal] = A.getRectGreenCellCenter(1,rectId);
    postCentroidAtOriginal = centroidAtOriginal;

    for frame =1 : A.numOfImages
        [boundingBoxAtOriginal, centroidAtOriginal] = A.getRectGreenCellCenter(frame,rectId);
        preCentroidAtOriginal = postCentroidAtOriginal;
        postCentroidAtOriginal = centroidAtOriginal;

        % 速度計測
        listRectGreenCellCenterDelta(frame,rectId) = ...
            norm(postCentroidAtOriginal - preCentroidAtOriginal);
        
        listRectGreenCellLine(rectId, (2*frame)-1) = centroidAtOriginal(1);
        listRectGreenCellLine(rectId, (2*frame)) = centroidAtOriginal(2);
        
        %
        disp(frame)
    end
end

xNum = A.numOfImages;
plot([1:xNum], listRectGreenCellCenterDelta(:,1), ...
    [1:xNum], listRectGreenCellCenterDelta(:,2))

listSmoothed(:,1) = smooth(listRectGreenCellCenterDelta(:,1));
listSmoothed(:,2) = smooth(listRectGreenCellCenterDelta(:,2));
plot([1:xNum], listSmoothed(:,1), ...
    [1:xNum], listSmoothed(:,2))

%
% figure
% I = A.getOriginalImage(1);
% Iline = insertShape(I, 'Line', listRectGreenCellLine', ...
%     'LineWidth', 5, 'color', 'red');
% imshow(Iline)

%% 二画面表示　左がRectとライン　右が速度のグラフ
%
rectIdList = [1 2];

% 速度を取得
list = A.getRectCenterDeltaList(rectId); %

% greenCellCenter を用いて中心速度

% グラフを固定するためのxlim, xylimの計算
xNum = A.numOfImages;
xlimVal = [0,xNum];
ylimVal = [0,max(list,[],'all')*1.1]; % 最大よりも10%上

% 基本設定
outputFolder = 'outFolder2GreenCell';
mkdir(outputFolder);

h = figure('Units','normalized','Position',[0.05 0.05 0.9 0.5],'Visible','on');

% 二画面表示
for frame =1 : A.numOfImages;
%for frame=100:100 % テスト用
    subplot(1,2,1)
    I = A.getMultipleRectAndCenterLine(frame, rectIdList, frame);
    imshow(I)

    subplot(1,2,2)
    plot([1:frame], listSmoothed(1:frame,1),'Color',A.rect(1).colorMapVal)
    hold on
    plot([1:frame], listSmoothed(1:frame,2),'Color',A.rect(2).colorMapVal)
%    plot(list(1:frame))
    xlim(xlimVal);
    ylim(ylimVal);
    title('移動速度')
    hold off

    outFileName =fullfile(outputFolder,sprintf('%04d.png',frame));
    saveas(gcf, outFileName);
    frame
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

