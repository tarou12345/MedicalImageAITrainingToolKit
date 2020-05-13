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
A.viewRectedImage(1,1)
A.viewRectInsertedImage(1,1)

%% 複数のRectを画像に埋め込む
frame = 1;
I = A.getMultipleRectedImage(frame, [1 2]);
imshow(I)

%% RectCenterLine
frame = 1;
rectId = 1;
A.viewRectCenterLine(frame, rectId);

%% 複数の RectCenterLine
frame = 1;
I = A.getMultipleRectCenterLineImage(frame, [1 2]);
imshow(I)


%% 画像にラインを書き込み

I = A.getOriginalImage(1);
Iinserted = insertShape(I, ...
    'Line', centerListsCell, 'LineWidth', 5, 'Color', colorMapVal*255);
imshow(Iinserted)

%%
