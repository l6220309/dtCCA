clc
clear

fun_calculate_ssvep_template(1); % run it if you do not have 'th_ssvep_template_for_stcca.mat'
ACC1 = [];
ACC2 = [];
ACC3 = [];
ITR1 = [];
ITR2 = [];
ITR3 = [];
for  tw = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
    k=15; 
    % tw=0.7;
    f_idx=round((40/k*[1:k]+40/k*[0:k-1])/2);
    [sub_acc1,sub_acc2,sub_acc3]=fun_dtcca(f_idx,1,tw,1);
    all_sub_itr1=itr_bci(sub_acc1/100,40,(tw+0.5)*ones(35,1));
    all_sub_itr2=itr_bci(sub_acc2/100,40,(tw+0.5)*ones(35,1));
    all_sub_itr3=itr_bci(sub_acc3/100,40,(tw+0.5)*ones(35,1));
    ACC1 = [ACC1;sub_acc1'];
    ACC2 = [ACC2;sub_acc2'];
    ACC3 = [ACC3;sub_acc3'];

    ITR1 = [ITR1;all_sub_itr1];
    ITR2 = [ITR2;all_sub_itr2];
    ITR3 = [ITR3;all_sub_itr3];
end



%% fun_calculate_ssvep_template(2); % run it if you do not have 'beta_ssvep_template_for_stcca.mat'
% ACC1 = [];
% ACC2 = [];
% ACC3 = [];
% ITR1 = [];
% ITR2 = [];
% ITR3 = [];
% for  tw = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
%     k=15; 
%     % tw=0.7;
%     f_idx=round((40/k*[1:k]+40/k*[0:k-1])/2);
%     [sub_acc1,sub_acc2,sub_acc3]=fun_dtcca(f_idx,1,tw,2);
%     all_sub_itr1=itr_bci(sub_acc1/100,40,(tw+0.5)*ones(70,1));
%     all_sub_itr2=itr_bci(sub_acc2/100,40,(tw+0.5)*ones(70,1));
%     all_sub_itr3=itr_bci(sub_acc3/100,40,(tw+0.5)*ones(70,1));
%     ACC1 = [ACC1;sub_acc1'];
%     ACC2 = [ACC2;sub_acc2'];
%     ACC3 = [ACC3;sub_acc3'];
% 
%     ITR1 = [ITR1;all_sub_itr1];
%     ITR2 = [ITR2;all_sub_itr2];
%     ITR3 = [ITR3;all_sub_itr3];
% end

