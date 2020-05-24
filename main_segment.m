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
A.changeFont()

%% 元画像の表示
frame = 1;
I = A.getOriginalImage(frame);
imshow(I)
A.titleFrame(frame);

%% 元画像　＋　単一セグメント　を取得
frame = 1;
segmentId = 1;
I = A.getSegmentFusionImage(frame,segmentId);
imshow(I)
%A.titleSegmentName(segmentId)
A.titleFrameAndSegmentName(frame, segmentId)

%% 元画像　＋　単一セグメント　を表示
frame = 1;
labelId = 1;
A.viewSegmentFusionImage(frame,labelId)

%% 元画像　＋　複数セグメント　を表示
frame = 1;
segmentIdList = [1 2];
A.viewMultipleSegmentFusionImage(frame,segmentIdList);

%% 元画像　＋　複数セグメント + ラベル名　を表示
frame = 1;
segmentIdList = [1 2];
I = A.getMultipleSegmentFusionImage(frame,segmentIdList);
I = A.insertMultipleSegmentLabelName(frame, segmentIdList, I);
imshow(I)

%%
% 日本語の挿入　上書き挿入になっている
textJp = '何とか日本語が入るようになった';
I = A.insertTextAtSegmentCenter(frame, 1, I, textJp);
imshow(I)

%% % 元画像なし

%% 全セグメントをIDごとに色付けして表示
frame = 1;
A.viewSegmentIndexColorImage(frame)

%% 特定のセグメントを抽出して色付け (元画像なし)
frame = 1;
segmentId = 1;
I = A.getSingleSegmentImageWithColor(frame, segmentId);
imshow(I)

%% 特定のセグメントを抽出して色付け表示 (元画像なし)
A.viewSingleSegmentImageWithColor(frame, segmentId)

%% segment 特定のsegmentId 画像を抽出
frame = 1;
segmentIdA = 1;
segmentIdB = 2;
I = A.getSingleSegmentImageWithColor(frame, segmentIdA);
I = A.insertSegmentImageWithColor(frame, segmentIdB, I);
imshow(I)

%% segment 特定のsegmentId 画像を抽出しラベル名を挿入
frame = 1;
segmentId = 1;

I = A.getSinglSegmentImageWithColorAndSegmentName(frame, segmentId);
imshow(I)

%% segment 特定のsegmentId 画像を抽出し「特定のテキスト」を挿入
frame = 1;
segmentId = 1;
text1 = "日本語の入力"

I = A.getSingleSegmentImageWithColor(frame, segmentId);
I = A.insertTextAtSegmentCenter(frame, segmentId, I, text1);
imshow(I)

%% segment 複数のsegmentId 画像を抽出しラベル名を挿入
frame = 1;
segmentIdA = 1;
segmentIdB = 2;

IA = A.getSinglSegmentImageWithColorAndSegmentName(frame, segmentIdA);
IB = A.getSinglSegmentImageWithColorAndSegmentName(frame, segmentIdB);
I = IA + IB;
imshow(I)

%% 複数のsegmentId 画像を抽出しラベル名を挿入
frame = 1;
segmentIdList = [1 2];
I = A.getMultipleSegmentImageWithColorAndSegmentName(frame, segmentIdList);
imshow(I)

%% 複数のsegmentId のsegmentを画像に挿入してラベル名も挿入
frame = 1;
segmentIdList = [1 2];
I = A.getMultipleSegmentFusionImage(frame, segmentIdList);
I = A.insertMultipleSegmentLabelName(frame, segmentIdList, I);
imshow(I)

%% 元画像に複数のセグメント+名前
frame = 1;
segmentIdList = [1 2];
I = A.getSegmentAndLabelAtOriginalImage(frame, segmentIdList);
imshow(I)

%% もと画像に複数のセグメント + 名前
A.viewSegmentAndLabelAtOriginalImage(frame, segmentIdList);

%% 動画作成
outputMovieFolder = 'outMovie';
movieFileName = 'test1.mp4';
segmentIdList = [1 2];
endOfFrame = 5; % デフォルトでは最終フレーム
frameRate = 5; % デフォルトでは30
movieType = 'MPEG-4'; % デフォルトではavi

A.makeSegmentMovie(movieFileName, outputMovieFolder, ...
                segmentIdList, endOfFrame, frameRate, movieType)

%% 動画を４Dに読み込み
% メモリ問題で失敗
% movie4d = ReadMovie2Memory('cellMoving.avi');


