classdef GTruthConverter
    % ���x���[�\�t�g�ō����gTruth�����Ƃɉ摜���쐬
    % 2020/5/8 segmentation�@�̂�
    % Todo : Rect�̒ǉ�
    
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
            % �C���X�^���X���쐬
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
            % ���摜�t�@�C�����̓ǂݍ���
            fileName = cell2mat(obj.labelFiles(frame));
        end
        
        function I = getOriginalImage(obj,frame)
            % ���摜�̓ǂݍ���
            fileName = obj.getOriginalImageFileName(frame);
            I = imread(fileName);
        end
        
        function fileName = getSegmentationFileName(obj,frame)
            % �Z�O�����e�[�V�����t�@�C�����̓ǂݍ���
            % ToDo�F�ǂݍ��݂Ɏ��s�����Ƃ���labelData�̉���ڂɂ��邩�m�F
            fileName = cell2mat(obj.labelData{frame,obj.LastRowOfLbelData});
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
        
        function Ic = getFusionImage(obj,frame, labelId)
            % labelId�̐F�̎擾
            colorMapVal = cell2mat(obj.labelDef.LabelColor(labelId, :));

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
    end
end

