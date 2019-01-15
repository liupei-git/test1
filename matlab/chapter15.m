%% SVM���������Ϣ����ʱ��ع�Ԥ��----��ָ֤������ָ���仯���ƺͱ仯�ռ�Ԥ�� 
%
% <html>
% <table border="0" width="600px" id="table1">	<tr>		<td><b><font size="2">�ð�������������</font></b></td>	</tr>	<tr>		<td><span class="comment"><font size="2">1�����˳���פ���ڴ�<a target="_blank" href="http://www.ilovematlab.cn/forum-158-1.html"><font color="#0000FF">���</font></a>���<a target="_blank" href="http://www.ilovematlab.cn/thread-48362-1-1.html"><font color="#0000FF">�ð���</font></a>���ʣ��������ʱش�</font></span></td></tr><tr>	<td><span class="comment"><font size="2">2���˰��������׵Ľ�ѧ��Ƶ�����׵�����������Matlab����</font></span></td>	</tr>	<tr>		<td><span class="comment"><font size="2">		3����������Ϊ�ð����Ĳ������ݣ�Լռ�ð����������ݵ�1/10����</font></span></td>	</tr>		<tr>		<td><span class="comment"><font size="2">		4���˰���Ϊԭ��������ת����ע��������<a target="_blank" href="http://www.ilovematlab.cn/">Matlab������̳</a>��<a target="_blank" href="http://www.ilovematlab.cn/forum-158-1.html">��Matlab������30������������</a>����</font></span></td>	</tr>		<tr>		<td><span class="comment"><font size="2">		5�����˰��������������о��й��������ǻ�ӭ���������Ҫ��ȣ����ǿ��Ǻ���Լ��ڰ����</font></span></td>	</tr>		<tr>		<td><span class="comment"><font size="2">		6������������������Ϊ���壬�鼮��ʵ�����ݿ�����������룬���鼮ʵ�ʷ�������Ϊ׼��</font></span></td>	</tr><tr>		<td><span class="comment"><font size="2">		7�����������������⡢Ԥ����ʽ�ȣ�<a target="_blank" href="http://www.ilovematlab.cn/thread-47939-1-1.html">��������</a>��</font></span></td>	</tr></table>
% </html>
%

%% ��ջ�������
function chapter15
tic;
close all;
clear;
clc;
format compact;
%% ԭʼ���ݵ���ȡ

% �������������ָ֤��(1990.12.19-2009.08.19)
% ������һ��4579*6��double�͵ľ���,ÿһ�б�ʾÿһ�����ָ֤��
% 6�зֱ��ʾ������ָ֤���Ŀ���ָ��,ָ�����ֵ,ָ�����ֵ,����ָ��,���ս�����,���ս��׶�.
load chapter15_sh.mat;

% ��ȡ����
ts = sh_open;
time = length(ts);

% ����ԭʼ��ָ֤����ÿ�տ�����
figure;
plot(ts,'LineWidth',2);
title('��ָ֤����ÿ�տ�����(1990.12.20-2009.08.19)','FontSize',12);
xlabel('����������(1990.12.19-2009.08.19)','FontSize',12);
ylabel('������','FontSize',12);
grid on;
% print -dtiff -r600 original;

snapnow;

%% ��ԭʼ���ݽ���ģ����Ϣ����

win_num = floor(time/5);
tsx = 1:win_num;
tsx = tsx';
[Low,R,Up]=FIG_D(ts','triangle',win_num);

% ģ����Ϣ�������ӻ�ͼ
figure;
hold on;
plot(Low,'b+');
plot(R,'r*');
plot(Up,'gx');
hold off;
legend('Low','R','Up',2);
title('ģ����Ϣ�������ӻ�ͼ','FontSize',12);
xlabel('����������Ŀ','FontSize',12);
ylabel('����ֵ','FontSize',12);
grid on;
% print -dtiff -r600 FIGpic;

snapnow;
%% ����SVM��Low���лع�Ԥ��

% ����Ԥ����,��Low���й�һ������
% mapminmaxΪmatlab�Դ���ӳ�亯��
[low,low_ps] = mapminmax(Low);
low_ps.ymin = 100;
low_ps.ymax = 500;
% ��Low���й�һ��
[low,low_ps] = mapminmax(low,low_ps);
% ����Low��һ�����ͼ��
figure;
plot(low,'b+');
title('Low��һ�����ͼ��','FontSize',12);
xlabel('����������Ŀ','FontSize',12);
ylabel('��һ���������ֵ','FontSize',12);
grid on;
% print -dtiff -r600 lowscale;
% ��low����ת��,�Է���libsvm����������ݸ�ʽҪ��
low = low';
snapnow;

% ѡ��ع�Ԥ���������ѵ�SVM����c&g
% ���Ƚ��д���ѡ��
[bestmse,bestc,bestg] = SVMcgForRegress(low,tsx,-10,10,-10,10,3,1,1,0.1,1);

% ��ӡ����ѡ����
disp('��ӡ����ѡ����');
str = sprintf( 'SVM parameters for Low:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% ���ݴ���ѡ��Ľ��ͼ�ٽ��о�ϸѡ��
[bestmse,bestc,bestg] = SVMcgForRegress(low,tsx,-4,8,-10,10,3,0.5,0.5,0.05,1);

% ��ӡ��ϸѡ����
disp('��ӡ��ϸѡ����');
str = sprintf( 'SVM parameters for Low:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% ѵ��SVM
cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) , ' -s 3 -p 0.1'];
low_model = svmtrain(low, tsx, cmd);

% Ԥ��
[low_predict,low_mse] = svmpredict(low,tsx,low_model);
low_predict = mapminmax('reverse',low_predict,low_ps);
predict_low = svmpredict(1,win_num+1,low_model);
predict_low = mapminmax('reverse',predict_low,low_ps);
predict_low

%% ����Low�Ļع�Ԥ��������
figure;
hold on;
plot(Low,'b+');
plot(low_predict,'r*');
legend('original low','predict low',2);
title('original vs predict','FontSize',12);
xlabel('����������Ŀ','FontSize',12);
ylabel('����ֵ','FontSize',12);
grid on;
print -dtiff -r600 lowresult;

figure;
error = low_predict - Low';
plot(error,'ro');
title('���(predicted data-original data)','FontSize',12);
xlabel('����������Ŀ','FontSize',12);
ylabel('�����','FontSize',12);
grid on;
print -dtiff -r600 lowresulterror;

snapnow;

%% ����SVM��R���лع�Ԥ��

% ����Ԥ����,��R���й�һ������
% mapminmaxΪmatlab�Դ���ӳ�亯��
[r,r_ps] = mapminmax(R);
r_ps.ymin = 100;
r_ps.ymax = 500;
% ��R���й�һ��
[r,r_ps] = mapminmax(R,r_ps);
% ����R��һ�����ͼ��
figure;
plot(r,'r*');
title('r��һ�����ͼ��','FontSize',12);
grid on;
% ��R����ת��,�Է���libsvm����������ݸ�ʽҪ��
r = r';
snapnow;

% ѡ��ع�Ԥ���������ѵ�SVM����c&g
% ���Ƚ��д���ѡ��
[bestmse,bestc,bestg] = SVMcgForRegress(r,tsx,-10,10,-10,10,3,1,1,0.1);

% ��ӡ����ѡ����
disp('��ӡ����ѡ����');
str = sprintf( 'SVM parameters for R:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% ���ݴ���ѡ��Ľ��ͼ�ٽ��о�ϸѡ��
[bestmse,bestc,bestg] = SVMcgForRegress(r,tsx,-4,8,-10,10,3,0.5,0.5,0.05);

% ��ӡ��ϸѡ����
disp('��ӡ��ϸѡ����');
str = sprintf( 'SVM parameters for R:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% ѵ��SVM
cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) , ' -s 3 -p 0.1'];
r_model = svmtrain(r, tsx, cmd);

% Ԥ��
[r_predict,r_mse] = svmpredict(r,tsx,low_model);
r_predict = mapminmax('reverse',r_predict,r_ps);
predict_r = svmpredict(1,win_num+1,r_model);
predict_r = mapminmax('reverse',predict_r,r_ps);
predict_r

%% ����R�Ļع�Ԥ��������
figure;
hold on;
plot(R,'b+');
plot(r_predict,'r*');
legend('original r','predict r',2);
title('original vs predict','FontSize',12);
grid on;
figure;
error = r_predict - R';
plot(error,'ro');
title('���(predicted data-original data)','FontSize',12);
grid on;
snapnow;

%% ����SVM��Up���лع�Ԥ��

% ����Ԥ����,��up���й�һ������
% mapminmaxΪmatlab�Դ���ӳ�亯��
[up,up_ps] = mapminmax(Up);
up_ps.ymin = 100;
up_ps.ymax = 500;
% ��Up���й�һ��
[up,up_ps] = mapminmax(Up,up_ps);
% ����Up��һ�����ͼ��
figure;
plot(up,'gx');
title('Up��һ�����ͼ��','FontSize',12);
grid on;
% ��up����ת��,�Է���libsvm����������ݸ�ʽҪ��
up = up';
snapnow;

% ѡ��ع�Ԥ���������ѵ�SVM����c&g
% ���Ƚ��д���ѡ��
[bestmse,bestc,bestg] = SVMcgForRegress(up,tsx,-10,10,-10,10,3,1,1,0.5);

% ��ӡ����ѡ����
disp('��ӡ����ѡ����');
str = sprintf( 'SVM parameters for Up:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% ���ݴ���ѡ��Ľ��ͼ�ٽ��о�ϸѡ��
[bestmse,bestc,bestg] = SVMcgForRegress(up,tsx,-4,8,-10,10,3,0.5,0.5,0.2);

% ��ӡ��ϸѡ����
disp('��ӡ��ϸѡ����');
str = sprintf( 'SVM parameters for Up:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% ѵ��SVM
cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) , ' -s 3 -p 0.1'];
up_model = svmtrain(up, tsx, cmd);

% Ԥ��
[up_predict,up_mse] = svmpredict(up,tsx,up_model);
up_predict = mapminmax('reverse',up_predict,up_ps);
predict_up = svmpredict(1,win_num+1,up_model);
predict_up = mapminmax('reverse',predict_up,up_ps);
predict_up

%% ����Up�Ļع�Ԥ��������
figure;
hold on;
plot(Up,'b+');
plot(up_predict,'r*');
legend('original up','predict up',2);
title('original vs predict','FontSize',12);
grid on;
figure;
error = up_predict - Up';
plot(error,'ro');
title('���(predicted data-original data)','FontSize',12);
grid on;
toc;
snapnow;
