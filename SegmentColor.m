classdef SegmentColor
    %SEGMENTCOLOR このクラスの概要をここに記述
    %   詳細説明をここに記述
    
    properties
        I
        Iseg
        labelId
        colorMapVal
        alphaVal
        Ib
        Ic
    end
    
    methods
        function obj = SegmentColor(I,Iseg,labelId,colorMapVal)
            % イニシャライズ
            obj.I = I;
            obj.Iseg = Iseg;
            obj.labelId = labelId;
            obj.colorMapVal = colorMapVal;
            
            % 透過性設定
            obj.alphaVal = 0.7;
            alphaVal = 0.7;
            
            % セグメントされた領域を抽出して色付け
            Ilogic = (Iseg == labelId);
            Imatch = 255 * uint8(Ilogic); % セグメント領域の抽出 
            Ib(:,:,1) = Imatch .* colorMapVal(1); % 色付け
            Ib(:,:,2) = Imatch .* colorMapVal(2);
            Ib(:,:,3) = Imatch .* colorMapVal(3);
            %imshow(Ib)

            % セグメントされていない領域を抽出して原画像を張り付け
            IlogicInv = ~Ilogic;
            IbInv = uint8(IlogicInv) .* I;
            %imshow(IbInv)

            % 両者を結合
            IbCombined = IbInv + Ib;
            %imshow(IbCombined)

            % alphaVal透過性に応じて結合
            Ia = I;
            Ic = (Ia .* alphaVal) + (IbCombined .* (1-alphaVal));
            %imshow(IC)
            
            % 記録
            obj.Ic = Ic; % 合成画像
            obj.Ib = Ib; % 
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            outputArg = obj.Property1 + inputArg;
        end
    end
end

