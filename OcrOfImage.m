classdef OcrOfImage
    % 画像のOCR
    
    properties
        I
        
        ocrResults

        numOfWords
    end
    
    methods
        function obj = OcrOfImage(I)
            % このクラスのインスタンスを作成
            ocrResults = ocr(I);
            numOfWords = size(ocrResults.Words,1); % 1であることに注意
            
            % 記録
            obj.I = I;
            obj.ocrResults = ocrResults;
            obj.numOfWords = numOfWords;
        end
        
        %% get
        function ocrResults = getOcrResults(obj)
            ocrResults = obj.ocrResults;
        end
        
        function I = getOriginalImage(obj)
            I = obj.I;
        end

        function I = getNumOfWords(obj)
            I = obj.numOfWords;
        end
        
        function words = getWords(obj, wordId)
            wordsCell = obj.ocrResults.Words(wordId);
            words = cell2mat(wordsCell);
        end

        %% 元画像を表示
        function showOriginalImage(obj)
            imshow(obj.I);
        end
        
        %% 画像に文字を挿入して表示
        function Iocr = insertAllWords2Image(obj)
            ocrResults = obj.ocrResults;
            Iocr = insertObjectAnnotation(obj.I, 'rectangle', ...
                ocrResults.WordBoundingBoxes, ...
                ocrResults.Words);
        end
        
        function showAllWordsAtImage(obj)
            Iocr = obj.insertAllWords2Image;
            imshow(Iocr)
        end
        
        %% 画像に特定のIdの文字を挿入して表示
        function Iocr = insertWordsById2Image(obj, wordId)
            % 画像に特定のIdの文字を挿入
            ocrResults = obj.ocrResults;
            Iocr = insertObjectAnnotation(obj.I, 'rectangle', ...
                ocrResults.WordBoundingBoxes(wordId,:), ...
                ocrResults.Words(wordId));
         end
        
        function showWordsAtImage(obj, wordId)
            % 画像に特定のIdの文字を挿入して表示
            Iocr = obj.insertWordsById2Image(wordId);
            imshow(Iocr)
        end
        
        %% 特定の文字の検索
        function tf = isExist(obj, text)
            % 特定の文字があるかを調べて返す
            tf = contains(obj.ocrResults.Words, text, 'IgnoreCase',true);
        end
        
        function indexOut = detectWordsAndReturnLogical(obj, text)
            % 特定の文字の有り無しインデックス
            for i=1:obj.numOfWords
                tf = contains(obj.ocrResults.Words(i), text, 'IgnoreCase',true);
                index(i) = tf;
            end
            indexOut = index;
        end
        
        function id = detectWordsId(obj, text)
            % 特定の文字を含むid
            indexOut = obj.detectWordsAndReturnLogical(text);
            id = find(indexOut);
        end
        
        function num = detectWordsAndCountNum(obj, text)
            % 特定の文字を含むidの数
            id = obj.detectWordsId(text);
            num = size(id,2);
        end
        
        function boundingBoxes = detectWordsAndReturnBoudingBoxes(obj, text)
            % 特定の文字を含むidの数
            id = obj.detectWordsId(text);
            boundingBoxes = obj.ocrResults.WordBoundingBoxes(id,:);
        end
        
        function [id, boundingBox] = detectWordsAndProperties(obj, text)
            id = obj.detectWordsId(text);
            boundingBox = obj.detectWordsAndReturnBoudingBoxes(text);
        end        
        
        %% 特定の文字を検索して画像に表示
        function I = detectWordsAndInsertWords2Image(obj, text)
            % 特定の文字を検索して画像に挿入
            id = obj.detectWordsId(text);
            I = obj.insertWordsById2Image(id);
        end
        
        function showDetectWordsAndInsertWords2Image(obj, text)
            I = obj.detectWordsAndInsertWords2Image(text);
            imshow(I);
            title(sprintf("Search: %s, Num: %d, Index: %s", ...
                text, ...
                obj.detectWordsAndCountNum(text), ...
                mat2str(obj.detectWordsId(text)))) % 数字をstrに変換
        end
    end
end

