classdef GTruthConverter
    % ラベラーソフトで作ったgTruthをもとに画像を作成
    % 2020/5/8 segmentation　のみ
    % Todo : Rectの追加
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
        
        alphaVal
        
        segment
        rect
        segmentCount
        rectCount
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
            
            %
            obj.alphaVal = 0.7;
            
            % ToDo: 変数の渡し方に問題あり
            A = SeparateLabelDef(gTruth);
            obj.segment = A.segment;
            obj.rect = A.rect;
            obj.segmentCount = A.segmentCount;
            obj.rectCount = A.rectCount;
            
        end
        
        function fileName = getOriginalImageFileName(obj,frame)
            % 原画像ファイル名の読み込み
            fileName = cell2mat(obj.labelFiles(frame));
        end
        
        function I = getOriginalImage(obj,frame)
            % 原画像の読み込み
            fileName = obj.getOriginalImageFileName(frame);
            I = imread(fileName);
        end
        
        %% segmentation 関係
        % ラベルの定義は obj.segment
        % ラベルのフレームごとの情報は obj.labelData

        % obj.rect
        function colorMapVal = getSegmentColorMapVal(obj,rectId)
            % Todo: insertShapeで256倍しないといけないときがある　原因不明
            % ToDo: cell配列の時と、そうじゃないときがある
            colorMapVal = obj.segment(rectId).colorMapVal;
            if iscell(colorMapVal)
                colorMapVal = cell2mat(colorMapVal);
            end
        end
        
        function name = getSegmentName(obj,rectId)
            name = obj.segment(rectId).name;
        end
        
        function name = getSegmentLabelIdAtLabelDefinition(obj,rectId)
            name = obj.segment(rectId).labelId;
        end
        
        % frameごとの処理
        function fileName = getSegmentFileName(obj,frame)
            % セグメンテーションファイル名の読み込み
            % ToDo：読み込みに失敗したときはlabelDataの何列目にあるか確認
            % 現在はlabelDataの最終列に存在するため LastRowOfLbelData を利用し
            % ているが将来は変更が必要
            fileName = cell2mat(obj.labelData{frame,obj.LastRowOfLbelData});
        end
        
        function validate = validateSegmentationDirName(obj)
            % セグメンテーションファイルを保存しているディレクトリが
            % 現在のディレクトリと同じかどうかをチェック
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
            I = obj.getSegmentImage(frame);
            imagesc(I)
        end
        
        function viewSegmentMontage(obj,frame)
            % モンタージュ画像の表示
            I = obj.getOriginalImage(frame);
            Iseg = obj.getSegmentImage(frame);
            % ToDo: *255は複数ラベルの時に困る
            montage({I, Iseg*255});
            title(sprintf('frame = %d/%d, labelNum = %d',frame, obj.numOfImages ,obj.numOfLabel));
        end

        function Ic = getSegmentFusionImage(obj,frame, labelId)
            % labelIdの色の取得
            colorMapVal = obj.getSegmentColorMapVal(labelId);

            % 原画像とセグメンテーション画像の読み込み
            I = obj.getOriginalImage(frame);
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
        
        %% Rect関係
        % ラベルの定義は obj.rect
        % ラベルのフレームごとの情報は obj.labelData
        
        % obj.rect 情報の取得
        function colorMapVal = getRectColorMapVal(obj,rectId)
            % Todo: insertShapeで256倍しないといけないときがある　原因不明
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
        
        function position = getRectPosition(obj,frame,rectId)
            % セグメンテーションファイルの読み込み
            % Todo: rectIdの指定
            position = cell2mat(obj.labelData{frame,rectId});
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
                numOfFrame = obj.numOfImages
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

