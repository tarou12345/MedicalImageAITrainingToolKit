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
            obj.rect = A.rect
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
        
        function fileName = getSegmentationFileName(obj,frame)
            % �Z�O�����e�[�V�����t�@�C�����̓ǂݍ���
            % ToDo�F�ǂݍ��݂Ɏ��s�����Ƃ���labelData�̉���ڂɂ��邩�m�F
            fileName = cell2mat(obj.labelData{frame,obj.LastRowOfLbelData});
        end
        
        function validate = validateSegmentationDirName(obj)
            % �Z�O�����e�[�V�����t�@�C����ۑ����Ă���f�B���N�g����
            % ���݂̃f�B���N�g���Ɠ������ǂ������`�F�b�N
            % ToDo:�@frame =1 �ɃZ�O�����e�[�V�����摜���Ȃ��Ɠ��삵�Ȃ��̂ŏC�����K�v
            frame = 1;
            fileName = obj.getSegmentationFileName(frame);
            currentDir = pwd;
            validate = contains(fileName, currentDir);            
        end
        
        function Iseg = getSegmentationImage(obj,frame)
            % �Z�O�����e�[�V�����t�@�C���̓ǂݍ���
            fileName = obj.getSegmentationFileName(frame);
            Iseg = imread(fileName);
        end
        
        function viewMontage(obj,frame)
            % �����^�[�W���摜�̕\��
            I = obj.getOriginalImage(frame);
            Iseg = obj.getSegmentationImage(frame);
            montage({I, Iseg*255});
            title(sprintf('frame = %d/%d, labelNum = %d',frame, obj.numOfImages ,obj.numOfLabel));
        end

        function colorMapVal = getColorMapVal(obj,segmentLabelId)
            % labelId�̐F�̎擾
            %colorMapVal = cell2mat(obj.labelDef.LabelColor(segmentLabelId, :));
            colorMapVal = obj.segment(segmentLabelId).colorMapVal;
        end
        
        function Ic = getFusionImage(obj,frame, labelId)
            % labelId�̐F�̎擾
            colorMapVal = obj.getColorMapVal(labelId);

            % ���摜�ƃZ�O�����e�[�V�����摜�̓ǂݍ���
            I = obj.getOriginalImage(frame);
            Iseg = obj.getSegmentationImage(frame);
            
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
        function position = getRectPosition(obj,frame,rectId)
            % �Z�O�����e�[�V�����t�@�C���̓ǂݍ���
            position = cell2mat(obj.labelData{frame,rectId});
        end
        
        
        
        
    end
end

