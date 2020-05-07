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
            
            %
            obj.alphaVal = 0.7;
            
            %
            
        end
        
        function I = getOriginalImage(obj,frame)
            % 原画像の読み込み
            fileName = cell2mat(obj.labelFiles(frame));
            I = imread(fileName);
        end
        
        function fileName = getOriginalImageFileName(obj,frame)
            % 原画像の読み込み
            fileName = cell2mat(obj.labelFiles(frame));
        end
        
        function fileName = getSegmentationFileName(obj,frame)
            % 原画像の読み込み
            % Todo: {frame,1} は1でよいのか？
            fileName = cell2mat(obj.labelData{frame,1});
        end
        
        function Iseg = getSegmentationImage(obj,frame)
            % 原画像の読み込み
            % Todo: {frame,1} は1でよいのか？
            fileName = cell2mat(obj.labelData{frame,1});
            Iseg = imread(imageFile);
        end
        
        function Iseg = viewMontage(obj,frame)
            imageName = cell2mat(obj.labelFiles(frame));
            I = imread(imageName);
            segmentName = cell2mat(obj.labelData{frame,1});
            Iseg = imread(segmentName);
            montage({I, Iseg*255});
            title(sprintf('frame = %d/%d, labelNum = %d',frame, obj.numOfImages ,obj.numOfLabel));
        end
        
        function Ic = getFusionImage(obj,frame, labelId)
            % labelIdの色の取得
            colorMapVal = cell2mat(obj.labelDef.LabelColor(labelId, :));

            % 原画像とセグメンテーション画像の読み込み
            % ToDo ここは呼び出しにしないとバグになりそう
            imageName = cell2mat(obj.labelFiles(frame));
            I = imread(imageName);
            segmentName = cell2mat(obj.labelData{frame,1});
            Iseg = imread(segmentName);
            
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

