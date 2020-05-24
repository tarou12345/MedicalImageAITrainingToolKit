classdef GTruthConverter
    % ���x���[�\�t�g�ō����gTruth�����Ƃɉ摜���쐬
    % 2020/5/8 segmentation�@�̂�
    % 5/12 Rect�ǉ�
    % 
    % �����K���Q��
    % https://qiita.com/KeithYokoma/items/2193cf79ba76563e3db6
    
    properties
        gTruth
        labelDef
        labelData
        labelFiles
        
        numOfLabel
        numOfImages
        LastRowOfLbelData
        
        % ���ߐ��̐ݒ�l
        alphaVal
        
        % ���{��\���̂��߂̃t�H���g�ݒ�
        fontName
        
        % SeparateLabelDef����擾������b���
        segment
        rect
        segmentCount
        rectCount
        
        % Rect��������
        settingOfRectGreenCellCenter
        rectGreenCellCenter
    end
    
    methods
        function obj = GTruthConverter(gTruth)
            % �C���X�^���X���쐬
            obj.gTruth = gTruth;
            obj.labelDef = gTruth.LabelDefinitions;
            obj.labelData = gTruth.LabelData;
            obj.labelFiles = gTruth.DataSource.Source;
            
            % 
            obj.numOfLabel = size(obj.labelDef,1);
            obj.numOfImages = size(obj.labelFiles,1);
            
            % �Z�O�����g�摜���L�^����Ă����ԍ�
            obj.LastRowOfLbelData = size(obj.labelData,2); %2
            
            % ���ߐ��̐ݒ�
            obj.alphaVal = 0.7;
            
            % �t�H���g�̎w��
            obj.fontName = 'Meiryo UI';
            
            % ToDo: �݌v���ÏL���A�����Ɨǂ����@������͂�
            A = SeparateLabelDef(gTruth);
            obj.segment = A.segment;
            obj.rect = A.rect;
            obj.segmentCount = A.segmentCount;
            obj.rectCount = A.rectCount;
            
            % �ݒ�
            obj.settingOfRectGreenCellCenter = 0; % �זE�̒��S
            obj.rectGreenCellCenter = struct;
        end
        
        %% �ݒ�̕ύX 
         % �t�H���g�̐ݒ�
        function obj = changeFont(obj)
            % �t�H���g�̕ύX
            fontJpStruct =  uisetfont();
            preFontName = obj.fontName;
            obj.fontName = fontJpStruct.FontName;
            obj.displayInCurrentFont('���{��', preFontName);
        end
        
        function displayInCurrentFont(obj,textJp,preFontName)
            % �t�H���g�̔�r�\���@�オ���݂̃t�H���g�A�����O��̃t�H���g
            arguments
                obj
                textJp = '���{��';
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
        
        
        %% ���摜
        function fileName = getOriginalImageFileName(obj,frame)
            % ���摜�t�@�C�����̓ǂݍ���
            fileName = cell2mat(obj.labelFiles(frame));
        end
        
        function I = getOriginalImage(obj,frame)
            % ���摜�̓ǂݍ���
            fileName = obj.getOriginalImageFileName(frame);
            I = imread(fileName);
        end
        
        function viewOriginalImage(obj, frame)
            I = obj.getOriginalImage(fram);
            imshow(I)
        end
        
        %% Title�@�\
        
        function text = titleTextFrame(obj, frame)
            % frame�ԍ��̃e�L�X�g���쐬
            text = sprintf("frame : %d/%d", frame, obj.numOfImages);
        end
        
        function text = titleTextSegmentName(obj, segmentId)
            % segment�ԍ��Ɩ��O�̃e�L�X�g���쐬
            text = sprintf("SegmentId : %d, LabelName : %s", ...
                segmentId, obj.getSegmentName(segmentId));
        end
        
        function titleFrame(obj,frame)
            % frame�ԍ��̃e�L�X�g���^�C�g����
            title(obj.titleTextFrame(frame))
        end
        
        function titleSegmentName(obj, segmentId)
            % segmentId �Ƃ��̖��O���^�C�g����
            title(obj.titleTextSegmentName(segmentId))
        end
        
        function titleFrameAndSegmentName(obj, frame, segmentId)
            % frame�ԍ��� segmentId���^�C�g����
            title(strcat(obj.titleTextFrame(frame), ", ",...
                obj.titleTextSegmentName(segmentId)))
        end        
        
        %% segment �S�̉����@�F�t��
        function Iout = getSegmentAndLabelAtOriginalImage(obj,frame,segmentIdList)
            I = obj.getMultipleSegmentFusionImage(frame, segmentIdList);
            I = obj.insertMultipleSegmentLabelName(frame, segmentIdList, I);
            Iout = I;
        end
        
        function viewSegmentAndLabelAtOriginalImage(obj,frame,segmentIdList)
            I = obj.getSegmentAndLabelAtOriginalImage(frame, segmentIdList);
            imshow(I);
        end
                
        %% segmentation �֌W
        % segment�̒�`�� obj.segment
        % segment�̃t�@�C������ obj.labelData

        function colorMapVal = getSegmentColorMapVal(obj,labelId)
            % segment �F�̎擾
            % Todo: insertShape��256�{���Ȃ��Ƃ����Ȃ��Ƃ�������@�����𒲂ׂ�ׂ�
            % ToDo: cell�z��̎��ƁA��������Ȃ��Ƃ�������
            colorMapVal = obj.segment(labelId).colorMapVal;
            if iscell(colorMapVal)
                colorMapVal = cell2mat(colorMapVal);
            end
        end
        
        function colorMapVal8bit = getSegmentColorMapValAs8bit(obj,labelId)
            % �����I��8bit�Ƃ��Ď擾
            colorMapVal = obj.getSegmentColorMapVal(labelId);
            colorMapVal8bit = uint8(colorMapVal *255);
        end        
        
        function name = getSegmentName(obj,labelId)
            % segment���̎擾
            name = obj.segment(labelId).name;
        end
        
        function name = getSegmentLabelIdAtLabelDefinition(obj,labelId)
            % segmentId �̎擾
            name = obj.segment(labelId).labelId;
        end
        
        function fileName = getSegmentFileName(obj,frame)
            % �Z�O�����e�[�V�����t�@�C�����̓ǂݍ���
            % ToDo�F�ǂݍ��݂Ɏ��s�����Ƃ���labelData�̉���ڂɂ��邩�m�F
            % ���݂�labelData�̍ŏI��ɑ��݂��邽�� LastRowOfLbelData �𗘗p��
            % �Ă��邪�����͕ύX���K�v
            fileName = cell2mat(obj.labelData{frame,obj.LastRowOfLbelData});
        end
        
        function validate = validateSegmentationDirName(obj)
            % segment �t�@�C�����ۑ�����Ă���Dir���J�����g�f�B���N�g���ɂ��邩�ǂ���
            % ToDo:�@frame =1 �ɃZ�O�����e�[�V�����摜���Ȃ��Ɠ��삵�Ȃ��̂ŏC�����K�v
            frame = 1;
            fileName = obj.getSegmentFileName(frame);
            currentDir = pwd;
            validate = contains(fileName, currentDir);            
        end
        
        function Iseg = getSegmentImage(obj,frame)
            % �Z�O�����e�[�V�����t�@�C���̓ǂݍ���
            fileName = obj.getSegmentFileName(frame);
            Iseg = imread(fileName);
        end
                           
        function viewSegmentImage(obj,frame)
            % imagesc �𗘗p���ă��x�����ƂɐF�����\�� 
            I = obj.getSegmentImage(frame);
            imagesc(I)
        end
        
        function viewSegmentMontage(obj,frame)
            % �����^�[�W���摜�̕\��
            I = obj.getOriginalImage(frame);
            Iseg = obj.getSegmentImage(frame);
            % ToDo: *255���ĖO�a�����ĕ\��
            montage({I, Iseg*255});
            title(sprintf('frame = %d/%d, labelNum = %d',frame, obj.numOfImages ,obj.numOfLabel));
        end
        
        %% segmentImage �S�̂̉���
        function Iout = getSegmentIndexColorImage(obj,frame)
            % segment ���ƂɐF���������摜 ���ׂĂ�segment���쐬
            I = obj.getSegmentImage(frame); % index��2d
            I3 = uint8(zeros(size(I,1),size(I,2),3));

            for i=1:obj.segmentCount
                colorMapVal = obj.getSegmentColorMapValAs8bit(i); % �����������F�̎擾
                Iid = uint8(I == i);
                Imixed = obj.mixLogicalImageAndColorMapVal(Iid, colorMapVal);
                I3 = I3 + Imixed;
            end
            Iout = I3;
        end
        
        function viewSegmentIndexColorImage(obj,frame)
            % segment ���ƂɐF���������摜 ���ׂĂ�segment��\��
            imshow(obj.getSegmentIndexColorImage(frame));
        end
        
        %% segment: segmentId ���Ƃ̏���
        
        function Ilogical = getSegmentLogicalOfSegmentId(obj, frame, segmentId)
            % frame�Ŏw�肵�� segment �ɂ���������segmentId �̗̈悾�����擾
            % ���ӁF�@�o�͂�logical
            I = obj.getSegmentImage(frame);
            Ilogical = (I == segmentId);
        end
        
        function Iout = mixLogicalImageAndColorMapVal(obj,Ilogical, colorMapVal)
            % [0-1]�̃��W�J���摜��colorMapVal�Ŏw�肵���F��t����
            Iid = uint8(Ilogical);
            Icolor(:,:,1) = Iid * colorMapVal(1);
            Icolor(:,:,2) = Iid * colorMapVal(2);
            Icolor(:,:,3) = Iid * colorMapVal(3);
            Iout = Icolor;
        end
        
        function s = getSegmentLogicalRegionCrops(obj, frame, segmentId)
            % regionprops��centroid��boundingBox��Area���܂ލ\���̂𓾂�
            % ToDo: �����̃Z�O�����g���������ꍇ�̔r���������ł��Ă��Ȃ��B
            % �ő�ʐς�segment�����������d�l�ɕύX����ׂ���
            s = regionprops(obj.getSegmentLogicalOfSegmentId(frame, segmentId));
        end
        
        function Itext = insertSegmentLabelName(obj, frame, segmentId, I)
            % ���x�������摜I�ɑ}���@���x�����A�ꏊ�������I��
            labelName = obj.getSegmentName(segmentId);
            Itext = obj.insertTextAtSegmentCenter(frame, segmentId, I, labelName);
        end
        
        function Itext = insertMultipleSegmentLabelName(obj, frame, segmentIdList, I)
            % �����̃��x�������摜I�ɑ}���@���x�����A�ꏊ�������I��
            for i=1:size(segmentIdList,2)
                labelName = obj.getSegmentName(segmentIdList(i));
                I = obj.insertTextAtSegmentCenter(frame, segmentIdList(i), I, labelName);
            end
            Itext = I;
        end
        
        function Itext = insertTextAtSegmentCenter(obj, frame, segmentId, I, text)
            % �����frame�̓����segment �̒��S���W�Ƀe�L�X�g��}��
            % ���{��ɑ΂��邽�߂�Font�ݒ�
            colorMapVal = obj.getSegmentColorMapValAs8bit(segmentId);
            position = obj.getSegmentCenter(frame, segmentId);
            
            Itext = insertText(I, position, text, 'BoxColor', colorMapVal, 'Font', obj.fontName);
        end
        
        function Iout = getSinglSegmentImageWithColorAndSegmentName(obj, frame, segmentId)
            % segment �F�t���摜���擾���āA���x������}��
            I = obj.getSingleSegmentImageWithColor(frame, segmentId);
            Iout = obj.insertSegmentLabelName(frame, segmentId, I);
        end
        
        function Iout = getMultipleSegmentImageWithColorAndSegmentName(obj, frame, segmentIdList)
            % segment �F�t���摜���擾���āA���x������}��
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
        
        %% segment �̒��S���W�̎擾
        function position = getSegmentCenter(obj, frame, segmentId)
            % segment�̒��S���W
            s = obj.getSegmentLogicalRegionCrops(frame, segmentId);
            position = s.Centroid;
        end
        
        function position = getSegmentLeftTop(obj, frame, segmentId)
            % segment�̍�����W
            s = obj.getSegmentLogicalRegionCrops(frame, segmentId);
            position = [s.BoundingBox(1), s.BoundingBox(2)];
        end

        function position = getSegmentRightBottom(obj, frame, segmentId)
            % segment�̉E�����W
            s = obj.getSegmentLogicalRegionCrops(frame, segmentId);
            position = [s.BoundingBox(1) + s.BoundingBox(3), s.BoundingBox(2)+ s.BoundingBox(4)];
        end
        
        %% segment �P��ID�̉摜�̎擾
        function Iout = getSingleSegmentImageWithColor(obj, frame, segmentId)
            % segment �摜���擾���� label�̐F�ɕϊ�
            Ilogical = obj.getSegmentLogicalOfSegmentId(frame, segmentId);
            colorMapVal = obj.getSegmentColorMapValAs8bit(segmentId);
            I = obj.mixLogicalImageAndColorMapVal(Ilogical, colorMapVal);
            Iout = I;
            %Iout = A.insertSegmentLabelName(frame, segmentId, I);
        end
        
        function viewSingleSegmentImageWithColor(obj,frame, segmentId)
            I = obj.getSingleSegmentImageWithColor(frame, segmentId);
            imshow(I)
            
            % Todo: �֐��ɑ}�����ꂽ�����������ň����p���Ń^�C�g���ɂł��Ȃ����H
            title(sprintf("frame=%d segmentId=%d ",frame,segmentId))
        end

        %% segment ����

        function Iout = insertSegmentImageWithColor(obj, frame, segmentId, I)
            % label�̐F�ɕϊ����� segment �摜�� ���͂����摜�ɒǉ� 
            Isegment = obj.getSingleSegmentImageWithColor(frame, segmentId);
            Iout = Isegment + I;
            %Iout = A.insertSegmentLabelName(frame, segmentId, I);
        end
                
        function Ic = getSegmentFusionImage(obj,frame, labelId)
            % �w��frame�̉摜I�� labelId�̃Z�O�����g���㏑��
            I = obj.getOriginalImage(frame);
            Ic = obj.insertSegmentImage2Image(frame, labelId, I);
        end
        
        function viewSegmentFusionImage(obj,frame, labelId)
            % �w��frame�̉摜I�� labelId�̃Z�O�����g���㏑�����ĕ\��
            I = obj.getSegmentFusionImage(frame, labelId);
            imshow(I)
        end
        
        function Ic = getMultipleSegmentFusionImage(obj, frame, segmentIdList)
            % �����̃��x���� �w��frame�̉摜�ɏ㏑��
            % segmentIdList = [1,2];
            I = obj.getOriginalImage(frame);
            
            for i=1:size(segmentIdList,2)
                I = obj.insertSegmentImage2Image(frame,segmentIdList(i),I);
            end
            Ic = I;
        end
        
        function viewMultipleSegmentFusionImage(obj, frame, segmentIdlist)
            % �����̃��x���� �w��frame�摜�ɏ㏑�����ĕ\��
            I = obj.getMultipleSegmentFusionImage(frame, segmentIdlist);
            imshow(I);
        end
            
        function Ic = insertSegmentImage2Image(obj,frame, labelId, I)
            % �摜I�Ɏw��frame�� labelId �̃Z�O�����g���㏑��
            % labelId�̐F�̎擾
            colorMapVal = obj.getSegmentColorMapVal(labelId);

            % ���摜�ƃZ�O�����e�[�V�����摜�̓ǂݍ���
            Iseg = obj.getSegmentImage(frame);
            
            % �Z�O�����g���ꂽ�̈�𒊏o���ĐF�t��
            Ilogic = (Iseg == labelId);
            Imatch = 255 * uint8(Ilogic); % �Z�O�����g�̈�̒��o 
            Ib(:,:,1) = Imatch .* colorMapVal(1); % �F�t��
            Ib(:,:,2) = Imatch .* colorMapVal(2);
            Ib(:,:,3) = Imatch .* colorMapVal(3);

            % �Z�O�����g����Ă��Ȃ��̈�𒊏o���Č��摜�𒣂�t��
            IlogicInv = ~Ilogic;
            IbInv = uint8(IlogicInv) .* I;

            % ���҂�����
            IbCombined = IbInv + Ib;

            % alphaVal���ߐ��ɉ����Č���
            Ia = I;
            Ic = (Ia .* obj.alphaVal) + (IbCombined .* (1-obj.alphaVal));
            %imshow(Ic)
        end
        
        %% ����쐬
        
        function makeSegmentMovie(obj, movieFileName, outputMovieFolder, ...
                segmentIdList, endOfFrame, frameRate, movieType)
            % �r�f�I�������ݐݒ�
            % ToDo: 
            arguments
                obj
                movieFileName = 'test2.mp4';
                outputMovieFolder = 'outMovie';
                segmentIdList = [1 2];
                endOfFrame = 5; % �f�t�H���g�ł͍ŏI�t���[��
                frameRate = 5; % �f�t�H���g�ł�30
                movieType = 'MPEG-4'; % �f�t�H���g�ł�avi
                %movieType = 'Motion JPEG AVI';
            end
            
            % �t�H���_�쐬
            % �@���̏��u�@�㏑���쐬���̌x����\�����Ȃ����߂�[~,~]
            %   ToDo: ��O�����̃A���S���Y����
            [~,~] = mkdir(outputMovieFolder);

            % �r�f�I�������ݏ���
            outputVideo = VideoWriter(fullfile(outputMovieFolder, movieFileName),movieType);
            outputVideo.FrameRate = frameRate; % �ݒ�̕ύX��open�O��
            open(outputVideo)

            % ���[�v
            for frame = 1:endOfFrame
                I = obj.getSegmentAndLabelAtOriginalImage(frame, segmentIdList);
                writeVideo(outputVideo, I);
            end

            % �r�f�I�I������
            close(outputVideo)
        end
        
        %% Rect�֌W
        % ���x���̒�`�� obj.rect
        % ���x���̃t���[�����Ƃ̏��� obj.labelData
        
        % obj.rect ���̎擾
        function colorMapVal = getRectColorMapVal(obj,rectId)
            % Todo: insertShape��255�{���Ȃ��Ƃ����Ȃ��Ƃ�������
            % [0-1]�Ȃ̂�[0-255]�Ȃ̂����肵�ē��ꂷ��ׂ�
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
        
        % obj.labelData�֌W�̓ǂݍ���
        % ToDo: LabelId�̗�ԍ���RectID����v���Ă���Ƃ��̂ݓ���
        % �����͏C�����K�v

        function position = getRectPositionOriginal(obj,frame,rectId)
            % ToDo�F�@�ݒ�ɂ��ύX�������Ȃ��@�ċA���̉���@���@���s
            position = cell2mat(obj.labelData{frame,rectId});
        end
        
        function position = getRectPosition(obj,frame,rectId)
            % Rect�̒��S
            position = obj.getRectPositionOriginal(frame,rectId);
            
        end
        
        % position �֌W
        function center = getRectCenter(obj,frame, rectId)
            position = obj.getRectPosition(frame, rectId);
            if isempty(position)
                center = [];
            else
            center = [position(1) + position(3)/2 , position(2) + position(4)/2 ];
            end
        end
            
        % rect �摜�֌W
        function Iinserted = getInsertRect2Image(obj,frame,rectId,I)
            %�u ����frame ��rect�v�����́u�摜I�v�ɑ}������i������}�����邽�߁j
            position = obj.getRectPosition(frame,rectId);
            % ToDo: 255�{���Ȃ��Ƃ����Ȃ����R���s��
            colorMapVal = obj.getRectColorMapVal(rectId) * 255;
            Iinserted = insertShape(I, ...
                'Rectangle', position, 'LineWidth', 5, 'Color', colorMapVal);
        end

        function Iinserted = getRectImage(obj,frame,rectId)
            % ����frame�̉摜�Ɏw�肵��rectId��rect��}���@1����
            I = obj.getOriginalImage(frame);
            Iinserted = obj.getInsertRect2Image(frame, rectId, I);
        end
        
        function viewRectImage(obj,frame,rectId)
            % �\��
            Iinserted = obj.getRectImage(frame,rectId);
            imshow(Iinserted)
        end
        
        %% Rect�̒��g
        function Iselected = getRectSelectedImage(obj,frame, rectId)
            % �����frame ��rect���̉摜���擾����
            position = obj.getRectPosition(frame, rectId);
            I = obj.getOriginalImage(frame);

            % ToDo: position�𐮐��ɕϊ��@�����ŕϊ�������������Ə㗬�ŕϊ����ׂ���
            position = round(position);
            Iselected = I(position(2):position(2)+position(4) , ...
                position(1):position(1)+position(3), :);
        end
        
        function viewRectSelectedImage(obj,frame,rectId)
            % �\��
            I = obj.getRectSelectedImage(frame, rectId);
            imshow(I)
        end
        
        function viewAllRectSelectedImage(obj, rectId)
            for frame=1:obj.numOfImages
                obj.viewRectSelectedImage(frame ,rectId)
            end
        end
        
        %% �΍זE�̒��S���W���擾
        
        function [boundingBoxAtOriginal, centroidAtOriginal] = ...
                getRectGreenCellCenter(obj, frame, rectId)
            % Rect���ɂ���΍זE�̒��S���W���擾 
            
            Irect = obj.getRectSelectedImage(frame,rectId);
            Ilab = rgb2lab(Irect); % lab�ɕϊ�
            Ilab2 = Ilab(:,:,2); % lab��2���擾�i�Ε����j
            Ilab2Index = (Ilab2<0); % 0�����̃C���f�b�N�X���擾
            %imshow(Ilab2Index)

            % regionprops ��p���ĕ���
            s = regionprops(Ilab2Index);

            % BoundingBox �̕\���m�F
            %boundingBox = [s(1).BoundingBox ; s(2).BoundingBox];
            %Irect = insertShape(I, 'Rectangle', boundingBox, ...
            %    'LineWidth', 5, 'Color', 'red');
            %imshow(Irect);
            
            % �ő�ʐς�BoundingBox��index���擾
            % max�֐��ŕ]���ł���悤�ɂ��邽�߂� [�\����.�v�f] 
            areaList = [s.Area]; 
            [~, index] = max(areaList);
            centroid = s(index).Centroid;
            boundingBox = [s(index).BoundingBox]; 

            % position
            %I = obj.getOriginalImage(frame); % ���摜
            position = obj.getRectPosition(frame,rectId);
            %  BoundingBox���Z��round���ꂽposition�Ōv�Z����Ă���̂�round
            position = round(position); 

            % boundingBox : [x1, y1, x2, y2] -> regionprops
            % position : [x, y, l, h ] -> insertShape
            % centroid : [x, y] -> regionprops
            % insertshape �� position�`���ł��邽�ߕϊ����K�v
            
            % BoundingBox���W�����̍��W�ɕϊ�
            position12 = [position(1), position(2)]; 
            centroidAtOriginal = position12 + centroid; % ToDo: position���� ���S���W��
            boundingBoxAtOriginal = [position12 , 0 , 0 ] + boundingBox;
            
            % ���W�m�F
            %Irect = insertShape(I, 'Rectangle', boundingBoxAtOriginal, ...
            %    'LineWidth', 5, 'Color', 'red');
            %imshow(Irect);
            
            positionGreenCellCenter = boundingBoxAtOriginal;
            
            % �ϐ��̎����o��
            % ToDo: ����͂�������[�B
            
            % ToDo:�@�Ȃ���obj.�ɑ���ł��Ȃ�
            % ->�@�߂�l��obj�������ĂȂ��@[?? ?? obj]�Ə����̂��H�������Ă���B
%             obj.rectGreenCellCenter(frame,rectId).position = position;
%             obj.rectGreenCellCenter(frame,rectId).s = s;
%             obj.rectGreenCellCenter(frame,rectId).index = index;
%             obj.rectGreenCellCenter(frame,rectId).centroidAtOriginal = centroidAtOriginal;
%             obj.rectGreenCellCenter(frame,rectId).boundingBoxAtOriginal = boundingBoxAtOriginal;
             
        end
                
        %% ������rect���摜�ɖ��ߍ���
        function ImultipleRect = getMultipleRect2Image(obj, frame, rectIdList, I)
            % �u����frame�̕�����rect�v���u����̉摜�v�ɓ����
            % rectIdList = [1 2];
            for i = 1 : length(rectIdList)
                I = obj.getInsertRect2Image(frame,rectIdList(i),I);
            end
            ImultipleRect = I;
        end
        
        function ImultipleRect = getMultipleRectImage(obj, frame, rectIdList)
            % �u����frame�̕�����rect�v���u����frame�̉摜�v�ɓ����
            % rectIdList = [1 2];
            I = obj.getOriginalImage(frame);
            ImultipleRect = obj.getMultipleRect2Image(frame, rectIdList,I);
        end
        
        function viewMultipleRectImage(obj, frame, rectIdList)
            I = obj.getMultipleRectImage(frame, rectIdList);
            imshow(I);
        end
        
        %% center List �� delta �̌v�Z
        function [centerListCellReturn, centerDeltaListReturn] = ...
                getRectCenterListAndDelta(obj, labelId, numOfFrame)
            % ToDo: �傫������̂ŕ������@�A���S���Y��������
            arguments
                obj
                labelId
                numOfFrame = obj.numOfImages % �����frame�܂Ŏ擾
            end
            
            numOfLine = 0; % ���̐�
            stateOfLine = 0; % �O��A�_�����������ǂ���
            centerList = []; % ���̓_�̃��X�g [x1,y1,x2,y2, ...]
            centerListCell = {}; % ���̃Z�� {[x1,y1,..],[x2,y2,...]}
            centerListWithNull = zeros(1,2); % �f�o�b�O�p
            centerDeltaList = [];
            
%             if numOfFrame == 0
%                 % numOfFrame == 0 ��������frame�w�肪�Ȃ��̂ōŏIframe
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
                   % �_������A�O�̓_�����݂��Ă���΋������v��
                   if stateOfLine == 1
                       centerPre = obj.getRectCenter(i-1, labelId);
                       centerDeltaList(i) = norm(centerPre - center);
                   else
                       centerDeltaList(i) = 0;
                   end
               end

               if and((stateOfLine == 0), not(isempty(center))) 
                   % �O��u�_�Ȃ��v�A����u�_����v�̎��A�V�������̊J�n�Ƃ݂Ȃ�
                   numOfLine = numOfLine + 1;
                   % 1�{�ڂ̐��̊J�n�ȊO�̎��ɁA�O��̐�(n-1)���L�^���ă��X�g��������
                   if numOfLine ~= 1
                       if size(centerList,2)<4                  
                           % ���W��4�ȏ�K�v
                           centerList = [centerList, centerList];
                       end
                       centerListCell(numOfLine-1) = {centerList};
                       centerList = [];
                   end
               end

               % �u�_����v�ł����centerList�ɒǉ��L�^
               if not(isempty(center))
                   centerList = [ centerList, center];
               end

               % �u�_�L��F�P�v�u�_�����F�O�v��Ԃ��L�^
               stateOfLine = ~isempty(center);
            end
            
            % �_���X�g���c���Ă���΃Z���ɒǉ��L�^
            if ~isempty(centerList)
               if size(centerList,2)<4                  
                   % ���W��4�ȏ�K�v
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
            % ���S���W�̃��X�g���擾
            [~, centerDeltaList] = obj.getRectCenterListAndDelta(labelId, numOfFrame);
        end
        
        function centerList = getRectCenterList(obj,labelId,numOfFrame)
            arguments
                obj
                labelId
                numOfFrame = obj.numOfImages
            end
            % ���S���W�̈ړ����x�̃��X�g���擾
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
            % ���S���ړ������O�Ղ��u�摜:I�v�ɑ}��
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
            % ���S���ړ������O�Ղ��摜�ɑ}���@1�{����
            I = obj.getOriginalImage(frame);
            Iinserted = obj.getInsertRectCenterLine2image(rectId,I,numOfFrame);
        end
        
        function viewRectCenterLine(obj,frame,rectId,numOfFrame)
            % ToDo: arguments �w�肪����قǕK�v�Ȃ̂̓A���S���Y���ɖ�肪����̂��H���p���@�� 
            arguments
                obj
                frame
                rectId
                numOfFrame = obj.numOfImages
            end
            % ���S���ړ������O�Ղ��摜�ɑ}�����ĕ\��
            imshow(obj.getRectCenterLine(frame,rectId,numOfFrame))
        end
        
        %% multi center Line
        function ImultipleRect = getMultipleRectCenterLineImage(obj, frame, rectIdList, numOfFrame)
            % ������rectCenterLine���摜�ɑ}��
            % frame�Ŏw�肵���摜�ɑ}��
            % ��@rectIdList = [1 2];
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
        
        %% multi �� rect��centerLine��\��
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
        
        %% �X�e�[�^�X�\��
        function dispData(obj)            % ������
            fprintf("pixel label: %d \n",obj.segmentCount)
            fprintf("rect label: %d \n",obj.rectCount)
            fprintf("\n");
        end
        
    end
end

