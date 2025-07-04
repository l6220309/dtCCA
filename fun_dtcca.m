function [sub_acc1,sub_acc2,sub_acc3]=fun_dtcca(f_idx,num_of_trials,TW,dataset_no)



if dataset_no==1
    str_dir='..\Benchmark\';
    ch_used=[48 54 55 56 57 58 61 62 63];       % Pz, PO5, PO3, POz, PO4, PO6, O1, Oz, O2
    pha_val=[0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 ...
        0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5]*pi;
    sti_f=[8.0:1:15.0, 8.2:1:15.2,8.4:1:15.4,8.6:1:15.6,8.8:1:15.8];
    n_sti=length(sti_f);                     % number of stimulus frequencies
    [~,target_order]=sort(sti_f);
    sti_f=sti_f(target_order);
    num_of_subj=35;
    ch_num = 9;
    latencyDelay=0.14;
    Fs=250;
elseif dataset_no==2
    str_dir='..\BETA\';
    ch_used=[48 54 55 56 57 58 61 62 63];       % Pz, PO5, PO3, POz, PO4, PO6, O1, Oz, O2
    pha_val=[0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 ...
        0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5 0 0.5 1 1.5]*pi;
    sti_f=[8.6:0.2:15.8,8.0 8.2 8.4];
    n_sti=length(sti_f);                     % number of stimulus frequencies
    [~,target_order]=sort(sti_f);
    sti_f=sti_f(target_order);
    num_of_subj=70;
    ch_num = 9;
    latencyDelay=0.13;
    Fs=250;
elseif dataset_no==3
    str_dir='..\UCSD\';
    % ch_used=[48 54 55 56 57 58 61 62 63];       % Pz, PO5, PO3, POz, PO4, PO6, O1, Oz, O2
    pha_val=[0 0 0 0 0 0 0 0 0 0 0 0]*pi;
    sti_f=[9.25, 11.25, 13.25, 9.75, 11.75, 13.75, 10.25, 12.25, 14.25, 10.75, 12.75, 14.75];
    n_sti=length(sti_f);                     % number of stimulus frequencies
    [~,target_order]=sort(sti_f);
    sti_f=sti_f(target_order);
    num_of_subj=10;
    ch_num = 8;
    latencyDelay=0.15;
    Fs=256;
else
end


temp_len=1*Fs;
num_of_harmonics=5;                         % for all cca
num_of_subbands=5;                          % for filter bank analysis

% butterworth filter
bandpass=[7 70];
[b1,a1]=butter(4,[bandpass(1)/(Fs/2) bandpass(2)/(Fs/2)]);
seed = RandStream('mt19937ar','Seed','shuffle');


for k=1:num_of_subbands
    bandpass1(1)=8*k;
    bandpass1(2)=90;
    [b2(k,:),a2(k,:)] = cheby1(4,1,[bandpass1(1)/(Fs/2) bandpass1(2)/(Fs/2)],'bandpass');
end
FB_coef0=[1:num_of_subbands].^(-1.25)+0.25;

if dataset_no==1
    load th_ssvep_template_for_stcca.mat
elseif dataset_no==2
    load beta_ssvep_template_for_stcca.mat
elseif dataset_no==3
    load ucsd_ssvep_template_for_stcca.mat
else
end

sig_len=length(subj(1).ssvep_template);
for k=1:num_of_subbands
    for sn=1:num_of_subj
        temp=[];
        ref=[];
        for m=1:n_sti
            tmp=subj(sn).ssvep_template(:,:,m);
            for ch_no=1:ch_num
                tmp_sb(ch_no,:)=filtfilt(b2(k,:),a2(k,:),tmp(ch_no,:));
            end
            subj(sn).subband(k).ssvep_template(:,:,m)=tmp_sb;
            temp=[temp tmp_sb];
            ref0=ck_signal_nh(sti_f(m),Fs,pha_val(m),sig_len,num_of_harmonics);
            ref=[ref ref0];
        end
        [W_x,W_y,r]=canoncorr(temp',ref');
        subj(sn).subband(k).sf=W_x(:,1);
        for m=1:n_sti
            ssvep_temp=subj(sn).subband(k).ssvep_template(:,:,m);
            subj(sn).subband(k).filtered_ssvep_template(m,:)=W_x(:,1)'*ssvep_temp;
        end
    end
end

sub_idx=[1:num_of_subj];



for sn=1:num_of_subj
    tic
    load([str_dir 'S' num2str(sn) '.mat']);
    if dataset_no==1
        eeg = data(ch_used,floor(0.5*Fs+latencyDelay*Fs):floor(0.5*Fs+latencyDelay*Fs)+4*Fs-1,:,:);
    elseif dataset_no==2
        eegdata = data.EEG;
        data = permute(eegdata,[1 2 4 3]);
        eeg = data(ch_used,floor(0.5*Fs+latencyDelay*Fs)+1:floor(0.5*Fs+latencyDelay*Fs)+2*Fs,:,:);
    elseif dataset_no==3
        data = permute(eeg,[2 3 1 4]);
        eeg = data(:,floor(1.0*Fs+latencyDelay*Fs)+1:floor(1.0*Fs+latencyDelay*Fs)+2*Fs,:,:);
    end
    
    
    
    [d1_,d2_,d3_,d4_]=size(eeg);
    d1=d3_;d2=d4_;d3=d1_;d4=d2_;
    no_of_class=d1;
    % d1: num of stimuli
    % d2: num of trials
    % d3: num of channels % Pz, PO5, PO3, POz, PO4, PO6, O1, Oz, O2
    % d4: num of sampling points
    
    for i=1:1:d1
        for j=1:1:d2
            y0=reshape(eeg(:,:,i,j),d3,d4);
            for ch_no=1:d3
                % CAR
                y0(ch_no,:)=y0(ch_no,:)-mean(y0([1:ch_no-1,ch_no+1:end],:));
                y(ch_no,:)=filtfilt(b1,a1,y0(ch_no,:));
            end
            for sub_band=1:num_of_subbands
                for ch_no=1:d3
                    y_sb(ch_no,:)=filtfilt(b2(sub_band,:),a2(sub_band,:),y(ch_no,:));
                end
                subband_signal(sub_band).SSVEPdata(:,:,j,i)=reshape(y_sb,d3,d4,1,1);
            end
        end
    end
    
    clear eeg
    %% Initialization
    
    TW_p=round(TW*Fs);
    n_run=d2;                                % number of used runs
    for sub_band=1:num_of_subbands
        subband_signal(sub_band).SSVEPdata=subband_signal(sub_band).SSVEPdata(:,:,:,target_order);
    end
    
    FB_coef=FB_coef0'*ones(1,n_sti);
    n_correct=zeros(length(TW),3);
    
    
    %% Classify
    seq_0=zeros(d2,num_of_trials);
    for run=1:d2
        %         % leave-one-run-out cross-validation
        if (num_of_trials==1)
            seq1=run;
        elseif (num_of_trials==d2-1)
            seq1=[1:n_run];
            seq1(run)=[];
        else
            % leave-one-run-out cross-validation
            isOK=0;
            while (isOK==0)
                seq=randperm(seed,d2);
                seq1=seq(1:num_of_trials);
                seq1=sort(seq1);
                if isempty(find(sum((seq1'*ones(1,d2)-seq_0').^2)==0))
                    isOK=1;
                end
            end
            
        end
        idx_traindata=seq1;
        idx_testdata=1:n_run;
        idx_testdata(seq1)=[];
        
        for i=1:no_of_class
            for k=1:num_of_subbands
                if length(idx_traindata)>1
                    subband_signal(k).signal_template(i,:,:)=mean(subband_signal(k).SSVEPdata(:,:,idx_traindata,i),3);
                else
                    subband_signal(k).signal_template(i,:,:)=subband_signal(k).SSVEPdata(:,:,idx_traindata,i);
                end
            end
        end
        
        % Training stage:
        % Find the intra-subject spatial filter
        for k=1:num_of_subbands
            target_ssvep=[];target_ref=[];
            for fn=1:length(f_idx)
                tmp1=reshape(subband_signal(k).signal_template(f_idx(fn),:,1:temp_len),d3,temp_len);
                ref1=ck_signal_nh(sti_f(f_idx(fn)),Fs,pha_val(f_idx(fn)),temp_len,num_of_harmonics);
                target_ssvep=[target_ssvep tmp1];
                target_ref=[target_ref ref1];
            end
            [W_x,W_y,r]=canoncorr(target_ssvep',target_ref');
            subband_signal(k).Wx=W_x(:,1);
            subband_signal(k).Wy=W_y(:,1);            
            tar_subj_sf=W_x(:,1);
            
            
            % Find the weights for constructing the inter-subject SSVEP template
            source_idx=sub_idx;
            source_idx(sn)=[];
            % A=source_idx;
            % source_idx=A(randperm(numel(A), ourindex));


            source_ssvep_temp0=zeros(length(source_idx),temp_len*length(f_idx));          
            source_ssvep_temp=zeros(1,d4);
            source_ssvep_temp2=zeros(1,d4);
            
            for ssn=1:length(source_idx)
                stmp=[];
                for fn=1:length(f_idx)                   
                    tmp2=subj(source_idx(ssn)).subband(k).filtered_ssvep_template(f_idx(fn),1:temp_len);
                    stmp=[stmp tmp2];
                end
                source_ssvep_temp0(ssn,:)=stmp;
            end
            X=source_ssvep_temp0';
            Y=(tar_subj_sf'*target_ssvep)';
            W0=inv(X'*X)*X'*Y;
            W_template1=W0(:,1);
            


            %% Correct source templates
            for ssn=1:length(source_idx)
                stmp=[];
                for fn=1:length(f_idx)
                    tmp2=subj(source_idx(ssn)).subband(k).ssvep_template(:,1:temp_len,f_idx(fn));
                    stmp=[stmp tmp2];
                end
                P = target_ssvep*stmp'/(stmp*stmp');
                for m=1:n_sti
                    correct_ssvep_temp = P * subj(source_idx(ssn)).subband(k).ssvep_template(:,1:sig_len,m);
                    subj(source_idx(ssn)).subband(k).filtered_ssvep_template2(m,:)=W_x(:,1)'*correct_ssvep_temp;
                end
            end

            if sum(abs(W_template1))==0
                W_template1=ones(1,34);
            end            
            for ssn=1:length(source_idx)                
                source_ssvep_temp=source_ssvep_temp+(W_template1(ssn))*subj(source_idx(ssn)).subband(k).filtered_ssvep_template;
                source_ssvep_temp2=source_ssvep_temp2+subj(source_idx(ssn)).subband(k).filtered_ssvep_template2;

            end
            source_ssvep_temp=source_ssvep_temp/sum(abs(W_template1)); 
            source_ssvep_temp2 = source_ssvep_temp2 / length(source_idx); 
            subband_signal(k).source_subject_filtered_template=source_ssvep_temp;
            subband_signal(k).source_subject_filtered_template2=source_ssvep_temp2;
        end
        
        % Testing stage:
        for run_test=1:length(idx_testdata)
            for tw_length=1:length(TW)                
                % sig_len=TW_p(tw_length);
                
                fprintf('stCCA Processing TW %fs, No. calibration %d, No.crossvalidation %d \n',TW(tw_length),length(f_idx)*length(idx_traindata), idx_testdata(run_test));
                
                for i=1:no_of_class
                    for sub_band=1:num_of_subbands
                        test_signal=subband_signal(sub_band).SSVEPdata(:,1:TW_p(tw_length),idx_testdata(run_test),i);
                        

                        for j=1:no_of_class                            
                            template=subband_signal(sub_band).source_subject_filtered_template(j,1:TW_p(tw_length));
                            template2=subband_signal(sub_band).source_subject_filtered_template2(j,1:TW_p(tw_length));   
                            ref=ck_signal_nh(sti_f(j),Fs,pha_val(j),TW_p(tw_length),num_of_harmonics);                          
                            
                            r1=corrcoef(subband_signal(sub_band).Wx'*test_signal,subband_signal(sub_band).Wy'*ref);
                            r2=corrcoef(subband_signal(sub_band).Wx'*test_signal,template);
                            r3=corrcoef(subband_signal(sub_band).Wx'*test_signal,template2);

                            R1(i,j)=r1(1,2);R2(i,j)=r2(1,2);R3(i,j)=r3(1,2);

                            myitR1(sub_band,j)=sign(r1(1,2))*r1(1,2)^2;
                            myitR2(sub_band,j)=sign(r1(1,2))*r1(1,2)^2+sign(r3(1,2))*r3(1,2)^2;
                            % myitR3(sub_band,j)=sign(r2(1,2))*r2(1,2)^2+sign(r3(1,2))*r3(1,2)^2;   
                            myitR3(sub_band,j)=sign(r1(1,2))*r1(1,2)^2+sign(r2(1,2))*r2(1,2)^2+sign(r3(1,2))*r3(1,2)^2;       
                        end
                    end
                    
                    itR1=sum((myitR1).*FB_coef,1);
                    itR2=sum((myitR2).*FB_coef,1);
                    itR3=sum((myitR3).*FB_coef,1);
                    
                    [~,idx1]=max(itR1);
                    if idx1==i
                        n_correct(tw_length,1)=n_correct(tw_length,1)+1;
                    end

                    [~,idx2]=max(itR2);
                    if idx2==i
                        n_correct(tw_length,2)=n_correct(tw_length,2)+1;
                    end

                    [~,idx3]=max(itR3);
                    if idx3==i
                        n_correct(tw_length,3)=n_correct(tw_length,3)+1;
                    end
                end
                
            end
            test_loss1(run_test) = sum(diag(R1));
            test_loss2(run_test) = (sum(diag(R1))+sum(diag(R2)))/2;
            test_loss3(run_test) = (sum(diag(R1))+sum(diag(R2))+sum(diag(R3)))/3;
        end
        seq_0(run,:)=seq1;
        all_loss1(run) = sum(test_loss1)/length(test_loss1);
        all_loss2(run) = sum(test_loss2)/length(test_loss2);
        all_loss3(run) = sum(test_loss3)/length(test_loss3);
    end
    %         idx_train_run(run,:)=idx_traindata;
    %         idx_test_run(run,:)=idx_testdata;
    %         seq_0(run,:)=seq1;
    %     end
    toc
    transfer_loss1(sn,:) = mean(all_loss1);
    transfer_loss2(sn,:) = mean(all_loss2);
    transfer_loss3(sn,:) = mean(all_loss3);
    accuracy=100*n_correct/n_sti/n_run/length(idx_testdata)
    sub_acc1(sn,:)=accuracy(:,1);
    sub_acc2(sn,:)=accuracy(:,2);
    sub_acc3(sn,:)=accuracy(:,3);
    disp(sn)    
end


