classdef GTruthConverter
    % ラベラーソフトで作ったgTruthをもとに画像を作成
    % 2020/5/8 segmentation　のみ
    % 5/12 Rect追加
    % 
    % 命名規則参照
    % https://qiita.com/KeithYokoma/items/2193cf79ba76563e3db6
    
    properties
        gTruth
        labelDef
        labelData
        labelFiles
        
        numOfLabel
        numOfImages
        LastRowOfLbelData
        
        % 透過性の設定値
        alphaVal
        
        % 日本語表示のためのフォント設定
        fontName
        
        % SeparateLabelDefから取得した基礎情報
        segment
        rect
        segmentCount
        rectCount
        
        % Rect内部処理
        settingOfRectGreenCellCenter
        rectGreenCellCenter
    end
    
    methods
        function obj = GTruthConverter(gTruth)
            % インスタンスを作成
            obj.gTruth = gTruth;
            obj.labelDef = gTruth.LabelDefinitions;
            obj.labelData = gTruth.LabelData;
            obj.labelFiles = gTruth.DataSource.Source;
            
            % 
            obj.numOfLabel = size(obj.labelDef,1);
            obj.numOfImages = size(obj.labelFiles,1);
            
            % セグメント画像が記録されている列番号
            obj.LastRowOfLbelData = size(obj.labelData,2); %2
            
            % 透過性の設定
            obj.alphaVal = 0.7;
            
            % フォントの指定
            obj.fontName = 'Meiryo UI';
            
            % ToDo: 設計が古臭い、もっと良い方法があるはず
            A = SeparateLabelDef(gTruth);
            obj.segment = A.segment;
            obj.rect = A.rect;
            obj.segmentCount = A.segmentCount;
            obj.rectCount = A.rectCount;
            
            % 設定
            obj.settingOfRectGreenCellCenter = 0; % 細胞の中心
            obj.rectGreenCellCenter = struct;
        end
        
        %% 設定の変更 
         % フォントの設定
        function obj = changeFont(obj)
            % フォントの変更
            fontJpStruct =  uisetfont();
            preFontName = obj.fontName;
            obj.fontName = fontJpStruct.FontName;
            obj.displayInCurrentFont('日本語', preFontName);
        end
        
        function displayInCurrentFont(obj,textJp,preFontName)
            % フォントの比較表示　上が現在のフォント、下が前回のフォント
            arguments
                obj
                textJp = '日本語';
                preFontName = '';
            end
            I = zeros(200,200,3);
            Ia = insertText(I,[20 20], textJp, 'Font', obj.fontName);
            Ib = insertText(Ia,[20 60], sprintf('current : %s',obj.fontName) , 'Font', obj.fontName);

            if ~isempty(preFontName)
                Ib = insertText(Ib,[20 120], textJp, 'Font', preFontName);
                Ib = insertText(Ib,[20 160], sprintf('pre : %s', preFontName), 'Font', preFontName);                
            end
                       
            imshow(Ib)
        end
        
        %%
        function obj = setRectGreenCellCenter(obj, property)
            obj.settingOfRectGreenCellCenter = property;
        end
        
        
        %% 元画像
        function fileName = getOriginalImageFileName(obj,frame)
            % 原画像ファイル名の読み込み
            fileName = cell2mat(obj.labelFiles(frame));
        end
        
        function I = getOriginalImage(obj,frame)
            % 原画像の読み込み
            fileName = obj.getOriginalImageFileName(frame);
            I = imread(fileName);
        end
        
        function viewOriginalImage(obj, frame)
            I = obj.getOriginalImage(fram);
            imshow(I)
        end
        
        %% Title機能
        
        function text = titleTextFrame(obj, frame)
            % frame番号のテキストを作成
            text = sprintf("frame : %d/%d", frame, obj.numOfImages);
        end
        
        function text = titleTextSegmentName(obj, segmentId)
            % segment番号と名前のテキストを作成
            text = sprintf("SegmentId : %d, LabelName : %s", ...
                segmentId, obj.getSegmentName(segmentId));
        end
        
        function titleFrame(obj,frame)
            % frame番号のテキストをタイトルに
            title(obj.titleTextFrame(frame))
        end
        
        function titleSegmentName(obj, segmentId)
            % segmentId とその名前をタイトルに
            title(obj.titleTextSegmentName(segmentId))
        end
        
        function titleFrameAndSegmentName(obj, frame, segmentId)
            % frame番号と segmentIdをタイトルに
            title(strcat(obj.titleTextFrame(frame), ", ",...
                obj.titleTextSegmentName(segmentId)))
        end        
        
        %% segment 全体可視化　色付け
        function Iout = getSegmentAndLabelAtOriginalImage(obj,frame,segmentIdList)
            I = obj.getMultipleSegmentFusionImage(frame, segmentIdList);
            I = obj.insertMultipleSegmentLabelName(frame, segmentIdList, I);
            Iout = I;
        end
        
        function viewSegmentAndLabelAtOriginalImage(obj,frame,segmentIdList)
            I = obj.getSegmentAndLabelAtOriginalImage(frame, segmentIdList);
            imshow(I);
        end
                
        %% segmentation 関係
        % segmentの定義は obj.segment
        % segmentのファイル情報は obj.labelData

        function colorMapVal = getSegmentColorMapVal(obj,labelId)
            % segment 色の取得
            % Todo: insertShapeで256倍しないといけないときがある　条件を調べるべき
            % ToDo: cell配列の時と、そうじゃないときがある
            colorMapVal = obj.segment(labelId).colorMapVal;
            if iscell(colorMapVal)
                colorMapVal = cell2mat(colorMapVal);
            end
        end
        
        function colorMapVal8bit = getSegmentColorMapValAs8bit(obj,labelId)
            % 明示的に8bitとして取得
            colorMapVal = obj.getSegmentColorMapVal(labelId);
            colorMapVal8bit = uint8(colorMapVal *255);
        end        
        
        function name = getSegmentName(obj,labelId)
            % segment名の取得
            name = obj.segment(labelId).name;
        end
        
        function name = getSegmentLabelIdAtLabelDefinition(obj,labelId)
            % segmentId の取得
            name = obj.segment(labelId).labelId;
        end
        
        function fileName = getSegmentFileName(obj,frame)
            % セグメンテーションファイル名の読み込み
            % ToDo：読み込みに失敗したときはlabelDataの何列目にあるか確認
            % 現在はlabelDataの最終列に存在するため LastRowOfLbelData を利用し
            % ているが将来は変更が必要
            fileName = cell2mat(obj.labelData{frame,obj.LastRowOfLbelData});
        end
        
        function validate = validateSegmentationDirName(obj)
            % segment ファイルが保存されているDirがカレントディレクトリにあるかどうか
            % ToDo:　frame =1 にセグメンテーション画像がないと動作しないので修正が必要
            frame = 1;
            fileName = obj.getSegmentFileName(frame);
            currentDir = pwd;
            validate = contains(fileName, currentDir);            
        end
        
        function Iseg = getSegmentImage(obj,frame)
            % セグメンテーションファイルの読み込み
            fileName = obj.getSegmentFileName(frame);
            Iseg = imread(fileName);
        end
                           
        function viewSegmentImage(obj,frame)
            % imagesc を利用してラベルごとに色分け表示 
            I = obj.getSegmentImage(frame);
            imagesc(I)
        end
        
        function viewSegmentMontage(obj,frame)
            % モンタージュ画像の表示
            I = obj.getOriginalImage(frame);
            Iseg = obj.getSegmentImage(frame);
            % ToDo: *255して飽和させて表示
            montage({I, Iseg*255});
            title(sprintf('frame = %d/%d, labelNum = %d',frame, obj.numOfImages ,obj.numOfLabel));
        end
        
        %% segmentImage 全体の可視化
        function Iout = getSegmentIndexColorImage(obj,frame)
            % segment ごとに色分けした画像 すべてのsegmentを作成
            I = obj.getSegmentImage(frame); % indexの2d
            I3 = uint8(zeros(size(I,1),size(I,2),3));

            for i=1:obj.segmentCount
                colorMapVal = obj.getSegmentColorMapValAs8bit(i); % 整数化した色の取得
                Iid = uint8(I == i);
                Imixed = obj.mixLogicalImageAndColorMapVal(Iid, colorMapVal);
                I3 = I3 + Imixed;
            end
            Iout = I3;
        end
        
        function viewSegmentIndexColorImage(obj,frame)
            % segment ごとに色分けした画像 すべてのsegmentを表示
            imshow(obj.getSegmentIndexColorImage(frame));
        end
        
        %% segment: segmentId ごとの処理
        
        function Ilogical = getSegmentLogicalOfSegmentId(obj, frame, segmentId)
            % frameで指定した segment における特定のsegmentId の領域だけを取得
            % 注意：　出力はlogical
            I = obj.getSegmentImage(frame);
            Ilogical = (I == segmentId);
        end
        
        function Iout = mixLogicalImageAndColorMapVal(obj,Ilogical, colorMapVal)
            % [0-1]のロジカル画像にcolorMapValで指定した色を付ける
            Iid = uint8(Ilogical);
            Icolor(:,:,1) = Iid * colorMapVal(1);
            Icolor(:,:,2) = Iid * colorMapVal(2);
            Icolor(:,:,3) = Iid * colorMapVal(3);
            Iout = Icolor;
        end
        
        function s = getSegmentLogicalRegionCrops(obj, frame, segmentId)
            % regionpropsでcentroidとboundingBoxとAreaを含む構造体を得る
            % ToDo: 複数のセグメントがあった場合の排他処理ができていない。
            % 最大面積のsegmentだけかえす仕様に変更するべきか
            s = regionprops(obj.getSegmentLogicalOfSegmentId(frame, segmentId));
        end
        
        function Itext = insertSegmentLabelName(obj, frame, segmentId, I)
            % ラベル名を画像Iに挿入　ラベル名、場所を自動的に
            labelName = obj.getSegmentName(segmentId);
            Itext = obj.insertTextAtSegmentCenter(frame, segmentId, I, labelName);
        end
        
        function Itext = insertMultipleSegmentLabelName(obj, frame, segmentIdList, I)
            % 複数のラベル名を画像Iに挿入　ラベル名、場所を自動的に
            for i=1:size(segmentIdList,2)
                labelName = obj.getSegmentName(segmentIdList(i));
                I = obj.insertTextAtSegmentCenter(frame, segmentIdList(i), I, labelName);
            end
            Itext = I;
        end
        
        function Itext = insertTextAtSegmentCenter(obj, frame, segmentId, I, text)
            % 特定のframeの特定のsegment の中心座標にテキストを挿入
            % 日本語に対するためにFont設定
            colorMapVal = obj.getSegmentColorMapValAs8bit(segmentId);
            position = obj.getSegmentCenter(frame, segmentId);
            
            Itext = insertText(I, position, text, 'BoxColor', colorMapVal, 'Font', obj.fontName);
        end
        
        function Iout = getSinglSegmentImageWithColorAndSegmentName(obj, frame, segmentId)
            % segment 色付き画像を取得して、ラベル名を挿入
            I = obj.getSingleSegmentImageWithColor(frame, segmentId);
            Iout = obj.insertSegmentLabelName(frame, segmentId, I);
        end
        
        function Iout = getMultipleSegmentImageWithColorAndSegmentName(obj, frame, segmentIdList)
            % segment 色付き画像を取得して、ラベル名を挿入
            Ipre = obj.getSinglSegmentImageWithColorAndSegmentName(frame, segmentIdList(1));
            if size(segmentIdList,2) > 1
                for i = 2:size(segmentIdList,2)
                    Ipost = obj.getSinglSegmentImageWithColorAndSegmentName(frame, segmentIdList(i));
                    Ipre = Ipre + Ipost;
                end
            end
            Iout = Ipre;
        end
        
        function viewMultiplSegmentImageWithColorAndSegmentName(obj, frame, segmentIdList)
            imshow(obj.getMultipleSegmentImageWithColorAndSegmentName(frame, segmentIdList));
        end
        
        %% segment の中心座標の取得
        function position = getSegmentCenter(obj, frame, segmentId)
            % segmentの中心座標
            s = obj.getSegmentLogicalRegionCrops(frame, segmentId);
            position = s.Centroid;
        end
        
        function position = getSegmentLeftTop(obj, frame, segmentId)
            % segmentの左上座標
            s = obj.getSegmentLogicalRegionCrops(frame, segmentId);
            position = [s.BoundingBox(1), s.BoundingBox(2)];
        end

        function position = getSegmentRightBottom(obj, frame, segmentId)
            % segmentの右下座標
            s = obj.getSegmentLogicalRegionCrops(frame, segmentId);
            position = [s.BoundingBox(1) + s.BoundingBox(3), s.BoundingBox(2)+ s.BoundingBox(4)];
        end
        
        %% segment 単独IDの画像の取得
        function Iout = getSingleSegmentImageWithColor(obj, frame, segmentId)
            % segment 画像を取得して labelの色に変換
            Ilogical = obj.getSegmentLogicalOfSegmentId(frame, segmentId);
            colorMapVal = obj.getSegmentColorMapValAs8bit(segmentId);
            I = obj.mixLogicalImageAndColorMapVal(Ilogical, colorMapVal);
            Iout = I;
            %Iout = A.insertSegmentLabelName(frame, segmentId, I);
        end
        
        function viewSingleSegmentImageWithColor(obj,frame, segmentId)
            I = obj.getSingleSegmentImageWithColor(frame, segmentId);
            imshow(I)
            
            % Todo: 関数に挿入された引数を自動で引き継いでタイトルにできないか？
            title(sprintf("frame=%d segmentId=%d ",frame,segmentId))
        end

        %% segment 合成

        function Iout = insertSegmentImageWithColor(obj, frame, segmentId, I)
            % labelの色に変換した segment 画像を 入力した画像に追加 
            Isegment = obj.getSingleSegmentImageWithColor(frame, segmentId);
            Iout = Isegment + I;
            %Iout = A.insertSegmentLabelName(frame, segmentId, I);
        end
                
        function Ic = getSegmentFusionImage(obj,frame, labelId)
            % 指定frameの画像Iに labelIdのセグメントを上書き
            I = obj.getOriginalImage(frame);
            Ic = obj.insertSegmentImage2Image(frame, labelId, I);
        end
        
        function viewSegmentFusionImage(obj,frame, labelId)
            % 指定frameの画像Iに labelIdのセグメントを上書きして表示
            I = obj.getSegmentFusionImage(frame, labelId);
            imshow(I)
        end
        
        function Ic = getMultipleSegmentFusionImage(obj, frame, segmentIdList)
            % 複数のラベルを 指定frameの画像に上書き
            % segmentIdList = [1,2];
            I = obj.getOriginalImage(frame);
            
            for i=1:size(segmentIdList,2)
                I = obj.insertSegmentImage2Image(frame,segmentIdList(i),I);
            end
            Ic = I;
        end
        
        function viewMultipleSegmentFusionImage(obj, frame, segmentIdlist)
            % 複数のラベルを 指定frame画像に上書きして表示
            I = obj.getMultipleSegmentFusionImage(frame, segmentIdlist);
            imshow(I);
        end
            
        function Ic = insertSegmentImage2Image(obj,frame, labelId, I)
            % 画像Iに指定frameの labelId のセグメントを上書き
            % labelIdの色の取得
            colorMapVal = obj.getSegmentColorMapVal(labelId);

            % 原画像とセグメンテーション画像の読み込み
            Iseg = obj.getSegmentImage(frame);
            
            % セグメントされた領域を抽出して色付け
            Ilogic = (Iseg == labelId);
            Imatch = 255 * uint8(Ilogic); % セグメント領域の抽出 
            Ib(:,:,1) = Imatch .* colorMapVal(1); % 色付け
            Ib(:,:,2) = Imatch .* colorMapVal(2);
            Ib(:,:,3) = Imatch .* colorMapVal(3);

            % セグメントされていない領域を抽出して原画像を張り付け
            IlogicInv = ~Ilogic;
            IbInv = uint8(IlogicInv) .* I;

            % 両者を結合
            IbCombined = IbInv + Ib;

            % alphaVal透過性に応じて結合
            Ia = I;
            Ic = (Ia .* obj.alphaVal) + (IbCombined .* (1-obj.alphaVal));
            %imshow(Ic)
        end
        
        %% 動画作成
        
        function makeSegmentMovie(obj, movieFileName, outputMovieFolder, ...
                segmentIdList, endOfFrame, frameRate, movieType)
            % ビデオ書き込み設定
            % ToDo: 
            arguments
                obj
                movieFileName = 'test2.mp4';
                outputMovieFolder = 'outMovie';
                segmentIdList = [1 2];
                endOfFrame = 5; % デフォルトでは最終フレーム
                frameRate = 5; % デフォルトでは30
                movieType = 'MPEG-4'; % デフォルトではavi
                %movieType = 'Motion JPEG AVI';
            end
            
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
                I = obj.getSegmentAndLabelAtOriginalImage(frame, segmentIdList);
                writeVideo(outputVideo, I);
            end

            % ビデオ終了処理
            close(outputVideo)
        end
        
        %% Rect関係
        % ラベルの定義は obj.rect
        % ラベルのフレームごとの情報は obj.labelData
        
        % obj.rect 情報の取得
        function colorMapVal = getRectColorMapVal(obj,rectId)
            % Todo: insertShapeで255倍しないといけないときがある
            % [0-1]なのか[0-255]なのか判定して統一するべき
            colorMapVal = obj.rect(rectId).colorMapVal;
            if iscell(colorMapVal)
                colorMapVal = cell2mat(colorMapVal);
            end
        end
        
        function name = getRectName(obj,rectId)
            name = obj.rect(rectId).name;
        end
        
        function name = getRectLabelIdAtLabelDefinition(obj,rectId)
            name = obj.rect(rectId).labelId;
        end
        
        % obj.labelData関係の読み込み
        % ToDo: LabelIdの列番号とRectIDが一致しているときのみ動作
        % 将来は修正が必要

        function position = getRectPositionOriginal(obj,frame,rectId)
            % ToDo：　設定による変更を許可しない　再帰問題の回避　→　失敗
            position = cell2mat(obj.labelData{frame,rectId});
        end
        
        function position = getRectPosition(obj,frame,rectId)
            % Rectの中心
            position = obj.getRectPositionOriginal(frame,rectId);
            
        end
        
        % position 関係
        function center = getRectCenter(obj,frame, rectId)
            position = obj.getRectPosition(frame, rectId);
            if isempty(position)
                center = [];
            else
            center = [position(1) + position(3)/2 , position(2) + position(4)/2 ];
            end
        end
            
        % rect 画像関係
        function Iinserted = getInsertRect2Image(obj,frame,rectId,I)
            %「 あるframe のrect」を特定の「画像I」に挿入する（複数回挿入するため）
            position = obj.getRectPosition(frame,rectId);
            % ToDo: 255倍しないといけない理由が不明
            colorMapVal = obj.getRectColorMapVal(rectId) * 255;
            Iinserted = insertShape(I, ...
                'Rectangle', position, 'LineWidth', 5, 'Color', colorMapVal);
        end

        function Iinserted = getRectImage(obj,frame,rectId)
            % あるframeの画像に指定したrectIdのrectを挿入　1個だけ
            I = obj.getOriginalImage(frame);
            Iinserted = obj.getInsertRect2Image(frame, rectId, I);
        end
        
        function viewRectImage(obj,frame,rectId)
            % 表示
            Iinserted = obj.getRectImage(frame,rectId);
            imshow(Iinserted)
        end
        
        %% Rectの中身
        function Iselected = getRectSelectedImage(obj,frame, rectId)
            % 特定のframe のrect内の画像を取得する
            position = obj.getRectPosition(frame, rectId);
            I = obj.getOriginalImage(frame);

            % ToDo: positionを整数に変換　ここで変換するよりももっと上流で変換すべきか
            position = round(position);
            Iselected = I(position(2):position(2)+position(4) , ...
                position(1):position(1)+position(3), :);
        end
        
        function viewRectSelectedImage(obj,frame,rectId)
            % 表示
            I = obj.getRectSelectedImage(frame, rectId);
            imshow(I)
        end
        
        function viewAllRectSelectedImage(obj, rectId)
            for frame=1:obj.numOfImages
                obj.viewRectSelectedImage(frame ,rectId)
            end
        end
        
        %% 緑細胞の中心座標を取得
        
        function [boundingBoxAtOriginal, centroidAtOriginal] = ...
                getRectGreenCellCenter(obj, frame, rectId)
            % Rect内にある緑細胞の中心座標を取得 
            
            Irect = obj.getRectSelectedImage(frame,rectId);
            Ilab = rgb2lab(Irect); % labに変換
            Ilab2 = Ilab(:,:,2); % labの2を取得（緑方向）
            Ilab2Index = (Ilab2<0); % 0未満のインデックスを取得
            %imshow(Ilab2Index)

            % regionprops を用いて分割
            s = regionprops(Ilab2Index);

            % BoundingBox の表示確認
            %boundingBox = [s(1).BoundingBox ; s(2).BoundingBox];
            %Irect = insertShape(I, 'Rectangle', boundingBox, ...
            %    'LineWidth', 5, 'Color', 'red');
            %imshow(Irect);
            
            % 最大面積のBoundingBoxのindexを取得
            % max関数で評価できるようにするために [構造体.要素] 
            areaList = [s.Area]; 
            [~, index] = max(areaList);
            centroid = s(index).Centroid;
            boundingBox = [s(index).BoundingBox]; 

            % position
            %I = obj.getOriginalImage(frame); % 元画像
            position = obj.getRectPosition(frame,rectId);
            %  BoundingBox演算はroundされたpositionで計算されているのでround
            position = round(position); 

            % boundingBox : [x1, y1, x2, y2] -> regionprops
            % position : [x, y, l, h ] -> insertShape
            % centroid : [x, y] -> regionprops
            % insertshape は position形式であるため変換が必要
            
            % BoundingBox座標を元の座標に変換
            position12 = [position(1), position(2)]; 
            centroidAtOriginal = position12 + centroid; % ToDo: positionから 中心座標は
            boundingBoxAtOriginal = [position12 , 0 , 0 ] + boundingBox;
            
            % 座標確認
            %Irect = insertShape(I, 'Rectangle', boundingBoxAtOriginal, ...
            %    'LineWidth', 5, 'Color', 'red');
            %imshow(Irect);
            
            positionGreenCellCenter = boundingBoxAtOriginal;
            
            % 変数の持ち出し
            % ToDo: これはあかんやろー。
            
            % ToDo:　なぜかobj.に代入できない
            % ->　戻り値にobjが入ってない　[?? ?? obj]と書くのか？実験してから。
%             obj.rectGreenCellCenter(frame,rectId).position = position;
%             obj.rectGreenCellCenter(frame,rectId).s = s;
%             obj.rectGreenCellCenter(frame,rectId).index = index;
%             obj.rectGreenCellCenter(frame,rectId).centroidAtOriginal = centroidAtOriginal;
%             obj.rectGreenCellCenter(frame,rectId).boundingBoxAtOriginal = boundingBoxAtOriginal;
             
        end
                
        %% 複数のrectを画像に埋め込む
        function ImultipleRect = getMultipleRect2Image(obj, frame, rectIdList, I)
            % 「あるframeの複数のrect」を「特定の画像」に入れる
            % rectIdList = [1 2];
            for i = 1 : length(rectIdList)
                I = obj.getInsertRect2Image(frame,rectIdList(i),I);
            end
            ImultipleRect = I;
        end
        
        function ImultipleRect = getMultipleRectImage(obj, frame, rectIdList)
            % 「あるframeの複数のrect」を「同じframeの画像」に入れる
            % rectIdList = [1 2];
            I = obj.getOriginalImage(frame);
            ImultipleRect = obj.getMultipleRect2Image(frame, rectIdList,I);
        end
        
        function viewMultipleRectImage(obj, frame, rectIdList)
            I = obj.getMultipleRectImage(frame, rectIdList);
            imshow(I);
        end
        
        %% center List と delta の計算
        function [centerListCellReturn, centerDeltaListReturn] = ...
                getRectCenterListAndDelta(obj, labelId, numOfFrame)
            % ToDo: 大きすぎるので分割を　アルゴリズムも汚い
            arguments
                obj
                labelId
                numOfFrame = obj.numOfImages % 特定のframeまで取得
            end
            
            numOfLine = 0; % 線の数
            stateOfLine = 0; % 前回、点があったかどうか
            centerList = []; % 線の点のリスト [x1,y1,x2,y2, ...]
            centerListCell = {}; % 線のセル {[x1,y1,..],[x2,y2,...]}
            centerListWithNull = zeros(1,2); % デバッグ用
            centerDeltaList = [];
            
%             if numOfFrame == 0
%                 % numOfFrame == 0 だったらframe指定がないので最終frame
%                 numOfFrame = obj.numOfImages;
%             else
%                 mumOfFrame = numOfFrame;
%             end

            for i=1:numOfFrame
               center = obj.getRectCenter(i,labelId);
               if isempty(center)
                   centerListWithNull(i,:) = [-1 -1 ];
                   centerDeltaList(i) = 0;
               else
                   centerListWithNull(i,1) = center(1);
                   centerListWithNull(i,2) = center(2);
                   % 点があり、前の点が存在していれば距離を計測
                   if stateOfLine == 1
                       centerPre = obj.getRectCenter(i-1, labelId);
                       centerDeltaList(i) = norm(centerPre - center);
                   else
                       centerDeltaList(i) = 0;
                   end
               end

               if and((stateOfLine == 0), not(isempty(center))) 
                   % 前回「点なし」、今回「点あり」の時、新しい線の開始とみなす
                   numOfLine = numOfLine + 1;
                   % 1本目の線の開始以外の時に、前回の線(n-1)を記録してリストを初期化
                   if numOfLine ~= 1
                       if size(centerList,2)<4                  
                           % 座標が4つ以上必要
                           centerList = [centerList, centerList];
                       end
                       centerListCell(numOfLine-1) = {centerList};
                       centerList = [];
                   end
               end

               % 「点あり」であればcenterListに追加記録
               if not(isempty(center))
                   centerList = [ centerList, center];
               end

               % 「点有り：１」「点無し：０」状態を記録
               stateOfLine = ~isempty(center);
            end
            
            % 点リストが残っていればセルに追加記録
            if ~isempty(centerList)
               if size(centerList,2)<4                  
                   % 座標が4つ以上必要
                   centerList = [centerList, centerList];
               end
               centerListCell(numOfLine) = {centerList};
            end
            
            centerListCellReturn = centerListCell;
            centerDeltaListReturn = centerDeltaList;
        end
        
        function centerDeltaList = getRectCenterDeltaList(obj,labelId,numOfFrame)
            arguments
                obj
                labelId
                numOfFrame = obj.numOfImages
            end
            % 中心座標のリストを取得
            [~, centerDeltaList] = obj.getRectCenterListAndDelta(labelId, numOfFrame);
        end
        
        function centerList = getRectCenterList(obj,labelId,numOfFrame)
            arguments
                obj
                labelId
                numOfFrame = obj.numOfImages
            end
            % 中心座標の移動速度のリストを取得
            [centerList, ~] = obj.getRectCenterListAndDelta(labelId, numOfFrame);
        end
        
        %% centerLine
        
        function Iinserted = getInsertRectCenterLine2image(obj,rectId,I,numOfFrame)
            arguments
                obj
                rectId
                I
                numOfFrame = obj.numOfImages
            end            
            % 中心が移動した軌跡を「画像:I」に挿入
            centerListCell = obj.getRectCenterList(rectId,numOfFrame);
            colorMapVal = obj.getRectColorMapVal(rectId);
            Iinserted = insertShape(I, ...
                'Line', centerListCell, 'LineWidth', 5, 'Color', colorMapVal*255);
        end
        
        function Iinserted = getRectCenterLine(obj,frame,rectId,numOfFrame)
            arguments
                obj
                frame
                rectId
                numOfFrame = obj.numOfImages
            end            
            % 中心が移動した軌跡を画像に挿入　1本だけ
            I = obj.getOriginalImage(frame);
            Iinserted = obj.getInsertRectCenterLine2image(rectId,I,numOfFrame);
        end
        
        function viewRectCenterLine(obj,frame,rectId,numOfFrame)
            % ToDo: arguments 指定がこれほど必要なのはアルゴリズムに問題があるのか？引継ぎ法を 
            arguments
                obj
                frame
                rectId
                numOfFrame = obj.numOfImages
            end
            % 中心が移動した軌跡を画像に挿入して表示
            imshow(obj.getRectCenterLine(frame,rectId,numOfFrame))
        end
        
        %% multi center Line
        function ImultipleRect = getMultipleRectCenterLineImage(obj, frame, rectIdList, numOfFrame)
            % 複数のrectCenterLineを画像に挿入
            % frameで指定した画像に挿入
            % 例　rectIdList = [1 2];
            arguments
                obj
                frame
                rectIdList
                numOfFrame = obj.numOfImages
            end
            
            I = obj.getOriginalImage(frame);
            for i = 1 : length(rectIdList)
                I = obj.getInsertRectCenterLine2image(rectIdList(i),I,numOfFrame);
            end
            ImultipleRect = I;
        end
        
        %% multi で rectとcenterLineを表示
        function Iout = getMultipleRectAndCenterLine(obj, frame, rectIdList, numOfFrame)
            arguments
                obj
                frame
                rectIdList
                numOfFrame = obj.numOfImages
            end
            I = obj.getMultipleRectCenterLineImage(frame, rectIdList, numOfFrame);
            Iout = obj.getMultipleRect2Image(frame, rectIdList, I);
        end
        
        %% delta
        function viewPlotOfCenterDeltaList(obj, rectId, numOfFrame)
            arguments
                obj
                rectId
                numOfFrame = obj.numOfImages
            end

            list = obj.getRectCenterDeltaList(rectId, numOfFrame);
            plot(list);
        end
        
        %% ステータス表示
        function dispData(obj)            % 現状を報告
            fprintf("pixel label: %d \n",obj.segmentCount)
            fprintf("rect label: %d \n",obj.rectCount)
            fprintf("\n");
        end
        
    end
end

