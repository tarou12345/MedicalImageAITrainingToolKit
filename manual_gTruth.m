%%
clear
% 機能一覧＋テスト

%% gTruth 読み込み
%load('gTruthCellMoving.mat')
load('gTruth.mat')

%%
A = GTruthConverter(gTruth);
% B = SeparateLabelDef(gTruth);

%%





%% ファイル書き出し

%% 動画に変換 [作業中] 逐一変換の実験

% ビデオ書き込み設定
outputMovieFolder = 'outMovie';
movieFileName = 'test2.mp4';
segmentIdList = [1 2];
endOfFrame = 5; % デフォルトでは最終フレーム
frameRate = 5; % デフォルトでは30
movieType = 'MPEG-4'; % デフォルトではavi
%movieType = 'Motion JPEG AVI';

% フォルダ作成
% 　仮の処置　上書き作成時の警告を表示しないために[~,~]
%   ToDo: 例外処理のアルゴリズムを
[~,~] = mkdir(outputMovieFolder);

% ビデオ書き込み準備
outputVideo = VideoWriter(fullfile(outputMovieFolder, movieFileName),movieType);
outputVideo.FrameRate = frameRate; % 設定の変更はopen前に
open(outputVideo)

% ループ
for frame = 1:endOfFrame
    I = A.getSegmentAndLabelAtOriginalImage(frame, segmentIdList);
    writeVideo(outputVideo, I);
end

% ビデオ終了処理
close(outputVideo)






