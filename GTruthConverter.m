classdef GTruthConverter
    % ラベラーソフトで作ったgTruthをもとに画像を作成
    % 2020/5/8 segmentation　のみ
    % Todo : Rectの追加
    
    properties
        gTruth
        labelDef
        labelData
        labelFiles
        
        numOfLabel
        numOfImages
        LastRowOfLbelData
        
        alphaVal
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
            obj.LastRowOfLbelData = size(obj.labelData,2); %2
            
            %
            obj.alphaVal = 0.7;
            
            %
            
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
        
        function fileName = getSegmentationFileName(obj,frame)
            % セグメンテーションファイル名の読み込み
            % ToDo：読み込みに失敗したときはlabelDataの何列目にあるか確認
            fileName = cell2mat(obj.labelData{frame,obj.LastRowOfLbelData});
        end
        
        function Iseg = getSegmentationImage(obj,frame)
            % セグメンテーションファイルの読み込み
            fileName = obj.getSegmentationFileName(frame);
            Iseg = imread(fileName);
        end
        
        function viewMontage(obj,frame)
            % モンタージュ画像の表示
            I = obj.getOriginalImage(frame);
            Iseg = obj.getSegmentationImage(frame);
            montage({I, Iseg*255});
            title(sprintf('frame = %d/%d, labelNum = %d',frame, obj.numOfImages ,obj.numOfLabel));
        end
        
        function Ic = getFusionImage(obj,frame, labelId)
            % labelIdの色の取得
            colorMapVal = cell2mat(obj.labelDef.LabelColor(labelId, :));

            % 原画像とセグメンテーション画像の読み込み
            I = obj.getOriginalImage(frame);
            Iseg = obj.getSegmentationImage(frame);
            
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
    end
end

