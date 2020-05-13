classdef GTruthConverter
    % ���x���[�\�t�g�ō����gTruth�����Ƃɉ摜���쐬
    % 2020/5/8 segmentation�@�̂�
    % Todo : Rect�̒ǉ�
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
        
        alphaVal
        
        segment
        rect
        segmentCount
        rectCount
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
            
            %
            obj.alphaVal = 0.7;
            
            % ToDo: �ϐ��̓n�����ɖ�肠��
            A = SeparateLabelDef(gTruth);
            obj.segment = A.segment;
            obj.rect = A.rect;
            obj.segmentCount = A.segmentCount;
            obj.rectCount = A.rectCount;
            
        end
        
        function fileName = getOriginalImageFileName(obj,frame)
            % ���摜�t�@�C�����̓ǂݍ���
            fileName = cell2mat(obj.labelFiles(frame));
        end
        
        function I = getOriginalImage(obj,frame)
            % ���摜�̓ǂݍ���
            fileName = obj.getOriginalImageFileName(frame);
            I = imread(fileName);
        end
        
        %% segmentation �֌W
        % ���x���̒�`�� obj.segment
        % ���x���̃t���[�����Ƃ̏��� obj.labelData

        % obj.rect
        function colorMapVal = getSegmentColorMapVal(obj,rectId)
            % Todo: insertShape��256�{���Ȃ��Ƃ����Ȃ��Ƃ�������@�����s��
            % ToDo: cell�z��̎��ƁA��������Ȃ��Ƃ�������
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
        
        % frame���Ƃ̏���
        function fileName = getSegmentFileName(obj,frame)
            % �Z�O�����e�[�V�����t�@�C�����̓ǂݍ���
            % ToDo�F�ǂݍ��݂Ɏ��s�����Ƃ���labelData�̉���ڂɂ��邩�m�F
            % ���݂�labelData�̍ŏI��ɑ��݂��邽�� LastRowOfLbelData �𗘗p��
            % �Ă��邪�����͕ύX���K�v
            fileName = cell2mat(obj.labelData{frame,obj.LastRowOfLbelData});
        end
        
        function validate = validateSegmentationDirName(obj)
            % �Z�O�����e�[�V�����t�@�C����ۑ����Ă���f�B���N�g����
            % ���݂̃f�B���N�g���Ɠ������ǂ������`�F�b�N
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
            I = obj.getSegmentImage(frame);
            imagesc(I)
        end
        
        function viewSegmentMontage(obj,frame)
            % �����^�[�W���摜�̕\��
            I = obj.getOriginalImage(frame);
            Iseg = obj.getSegmentImage(frame);
            % ToDo: *255�͕������x���̎��ɍ���
            montage({I, Iseg*255});
            title(sprintf('frame = %d/%d, labelNum = %d',frame, obj.numOfImages ,obj.numOfLabel));
        end

        function Ic = getSegmentFusionImage(obj,frame, labelId)
            % labelId�̐F�̎擾
            colorMapVal = obj.getSegmentColorMapVal(labelId);

            % ���摜�ƃZ�O�����e�[�V�����摜�̓ǂݍ���
            I = obj.getOriginalImage(frame);
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
        
        %% Rect�֌W
        % ���x���̒�`�� obj.rect
        % ���x���̃t���[�����Ƃ̏��� obj.labelData
        
        % obj.rect ���̎擾
        function colorMapVal = getRectColorMapVal(obj,rectId)
            % Todo: insertShape��256�{���Ȃ��Ƃ����Ȃ��Ƃ�������@�����s��
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
        
        function position = getRectPosition(obj,frame,rectId)
            % �Z�O�����e�[�V�����t�@�C���̓ǂݍ���
            % Todo: rectId�̎w��
            position = cell2mat(obj.labelData{frame,rectId});
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
        function Iinserted = getRectInsertedImage(obj,frame,rectId)
            position = obj.getRectPosition(frame,rectId);
            % ToDo: 255�{���Ȃ��Ƃ����Ȃ����R���s��
            colorMapVal = obj.getRectColorMapVal(1) * 255;
            I = obj.getOriginalImage(frame);
            Iinserted = insertShape(I, ...
                'Rectangle', position, 'LineWidth', 5, 'Color', colorMapVal);
        end
        
        function viewRectInsertedImage(obj,frame,rectId)
            Iinserted = obj.getRectInsertedImage(frame,rectId);
            imshow(Iinserted)
        end
        
        function Irect = getRectedImage(obj,frame,rectId)
            position = obj.getRectPosition(frame,rectId);
            I = obj.getOriginalImage(frame);
            Irect = I(position(2):position(2) + position(4), ...
                position(1):position(1) + position(3) );
        end
        
        function viewRectedImage(obj,frame,rectId)
            Irect = obj.getRectedImage(frame,rectId);
            imshow(Irect)
        end
        
        %% center ����
        function [centerListCellReturn, centerDeltaListReturn] = getRectCenterListAndDelta(obj,labelId)
            % ToDo: �傫������̂ŕ������@�A���S���Y��������
            numOfLine = 0; % ���̐�
            stateOfLine = 0; % �O��A�_�����������ǂ���
            centerList = []; % ���̓_�̃��X�g [x1,y1,x2,y2, ...]
            centerListCell = {}; % ���̃Z�� {[x1,y1,..],[x2,y2,...]}
            centerListWithNull = zeros(1,2); % �f�o�b�O�p
            centerDeltaList = [];

            for i=1:obj.numOfImages
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
        
        function centerDeltaList = getRectCenterDeltaList(obj,labelId)
            % ���S���W�̃��X�g���擾
            [~, centerDeltaList] = obj.getRectCenterListAndDelta(labelId);
        end
        
        function centerList = getRectCenterList(obj,labelId)
            % ���S���W�̈ړ����x�̃��X�g���擾
            [centerList, ~] = obj.getRectCenterListAndDelta(labelId);
        end
        
        %% center
        function Iinserted = getRectLine(obj,frame,rectId)
            % ���S���ړ������O�Ղ��摜�ɑ}��
            I = obj.getOriginalImage(frame);
            centerListCell = obj.getRectCenterList(rectId);
            colorMapVal = obj.getRectColorMapVal(rectId);
            Iinserted = insertShape(I, ...
                'Line', centerListCell, 'LineWidth', 5, 'Color', colorMapVal*255);
        end
        
        function viewRectLine(obj,frame,rectId)
            % ���S���ړ������O�Ղ��摜�ɑ}�����ĕ\��
            imshow(obj.getRectLine(frame,rectId))
        end
        
        %% delta
        function viewPlotOfCenterDeltaList(obj, rectId)
            list = obj.getRectCenterDeltaList(rectId);
            plot(list);
        end
        
        %%
        function dispData(obj)            % ������
            fprintf("pixel label: %d \n",obj.segmentCount)
            fprintf("rect label: %d \n",obj.rectCount)
            fprintf("\n");
        end
        
    end
end

