%% SVM神经网络的信息粒化时序回归预测----上证指数开盘指数变化趋势和变化空间预测 
%
% <html>
% <table border="0" width="600px" id="table1">	<tr>		<td><b><font size="2">该案例作者申明：</font></b></td>	</tr>	<tr>		<td><span class="comment"><font size="2">1：本人长期驻扎在此<a target="_blank" href="http://www.ilovematlab.cn/forum-158-1.html"><font color="#0000FF">板块</font></a>里，对<a target="_blank" href="http://www.ilovematlab.cn/thread-48362-1-1.html"><font color="#0000FF">该案例</font></a>提问，做到有问必答。</font></span></td></tr><tr>	<td><span class="comment"><font size="2">2：此案例有配套的教学视频，配套的完整可运行Matlab程序。</font></span></td>	</tr>	<tr>		<td><span class="comment"><font size="2">		3：以下内容为该案例的部分内容（约占该案例完整内容的1/10）。</font></span></td>	</tr>		<tr>		<td><span class="comment"><font size="2">		4：此案例为原创案例，转载请注明出处（<a target="_blank" href="http://www.ilovematlab.cn/">Matlab中文论坛</a>，<a target="_blank" href="http://www.ilovematlab.cn/forum-158-1.html">《Matlab神经网络30个案例分析》</a>）。</font></span></td>	</tr>		<tr>		<td><span class="comment"><font size="2">		5：若此案例碰巧与您的研究有关联，我们欢迎您提意见，要求等，我们考虑后可以加在案例里。</font></span></td>	</tr>		<tr>		<td><span class="comment"><font size="2">		6：您看到的以下内容为初稿，书籍的实际内容可能有少许出入，以书籍实际发行内容为准。</font></span></td>	</tr><tr>		<td><span class="comment"><font size="2">		7：此书其他常见问题、预定方式等，<a target="_blank" href="http://www.ilovematlab.cn/thread-47939-1-1.html">请点击这里</a>。</font></span></td>	</tr></table>
% </html>
%

%% 清空环境变量
function chapter15
tic;
close all;
clear;
clc;
format compact;
%% 原始数据的提取

% 载入测试数据上证指数(1990.12.19-2009.08.19)
% 数据是一个4579*6的double型的矩阵,每一行表示每一天的上证指数
% 6列分别表示当天上证指数的开盘指数,指数最高值,指数最低值,收盘指数,当日交易量,当日交易额.
load chapter15_sh.mat;

% 提取数据
ts = sh_open;
time = length(ts);

% 画出原始上证指数的每日开盘数
figure;
plot(ts,'LineWidth',2);
title('上证指数的每日开盘数(1990.12.20-2009.08.19)','FontSize',12);
xlabel('交易日天数(1990.12.19-2009.08.19)','FontSize',12);
ylabel('开盘数','FontSize',12);
grid on;
% print -dtiff -r600 original;

snapnow;

%% 对原始数据进行模糊信息粒化

win_num = floor(time/5);
tsx = 1:win_num;
tsx = tsx';
[Low,R,Up]=FIG_D(ts','triangle',win_num);

% 模糊信息粒化可视化图
figure;
hold on;
plot(Low,'b+');
plot(R,'r*');
plot(Up,'gx');
hold off;
legend('Low','R','Up',2);
title('模糊信息粒化可视化图','FontSize',12);
xlabel('粒化窗口数目','FontSize',12);
ylabel('粒化值','FontSize',12);
grid on;
% print -dtiff -r600 FIGpic;

snapnow;
%% 利用SVM对Low进行回归预测

% 数据预处理,将Low进行归一化处理
% mapminmax为matlab自带的映射函数
[low,low_ps] = mapminmax(Low);
low_ps.ymin = 100;
low_ps.ymax = 500;
% 对Low进行归一化
[low,low_ps] = mapminmax(low,low_ps);
% 画出Low归一化后的图像
figure;
plot(low,'b+');
title('Low归一化后的图像','FontSize',12);
xlabel('粒化窗口数目','FontSize',12);
ylabel('归一化后的粒化值','FontSize',12);
grid on;
% print -dtiff -r600 lowscale;
% 对low进行转置,以符合libsvm工具箱的数据格式要求
low = low';
snapnow;

% 选择回归预测分析中最佳的SVM参数c&g
% 首先进行粗略选择
[bestmse,bestc,bestg] = SVMcgForRegress(low,tsx,-10,10,-10,10,3,1,1,0.1,1);

% 打印粗略选择结果
disp('打印粗略选择结果');
str = sprintf( 'SVM parameters for Low:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% 根据粗略选择的结果图再进行精细选择
[bestmse,bestc,bestg] = SVMcgForRegress(low,tsx,-4,8,-10,10,3,0.5,0.5,0.05,1);

% 打印精细选择结果
disp('打印精细选择结果');
str = sprintf( 'SVM parameters for Low:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% 训练SVM
cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) , ' -s 3 -p 0.1'];
low_model = svmtrain(low, tsx, cmd);

% 预测
[low_predict,low_mse] = svmpredict(low,tsx,low_model);
low_predict = mapminmax('reverse',low_predict,low_ps);
predict_low = svmpredict(1,win_num+1,low_model);
predict_low = mapminmax('reverse',predict_low,low_ps);
predict_low

%% 对于Low的回归预测结果分析
figure;
hold on;
plot(Low,'b+');
plot(low_predict,'r*');
legend('original low','predict low',2);
title('original vs predict','FontSize',12);
xlabel('粒化窗口数目','FontSize',12);
ylabel('粒化值','FontSize',12);
grid on;
print -dtiff -r600 lowresult;

figure;
error = low_predict - Low';
plot(error,'ro');
title('误差(predicted data-original data)','FontSize',12);
xlabel('粒化窗口数目','FontSize',12);
ylabel('误差量','FontSize',12);
grid on;
print -dtiff -r600 lowresulterror;

snapnow;

%% 利用SVM对R进行回归预测

% 数据预处理,将R进行归一化处理
% mapminmax为matlab自带的映射函数
[r,r_ps] = mapminmax(R);
r_ps.ymin = 100;
r_ps.ymax = 500;
% 对R进行归一化
[r,r_ps] = mapminmax(R,r_ps);
% 画出R归一化后的图像
figure;
plot(r,'r*');
title('r归一化后的图像','FontSize',12);
grid on;
% 对R进行转置,以符合libsvm工具箱的数据格式要求
r = r';
snapnow;

% 选择回归预测分析中最佳的SVM参数c&g
% 首先进行粗略选择
[bestmse,bestc,bestg] = SVMcgForRegress(r,tsx,-10,10,-10,10,3,1,1,0.1);

% 打印粗略选择结果
disp('打印粗略选择结果');
str = sprintf( 'SVM parameters for R:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% 根据粗略选择的结果图再进行精细选择
[bestmse,bestc,bestg] = SVMcgForRegress(r,tsx,-4,8,-10,10,3,0.5,0.5,0.05);

% 打印精细选择结果
disp('打印精细选择结果');
str = sprintf( 'SVM parameters for R:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% 训练SVM
cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) , ' -s 3 -p 0.1'];
r_model = svmtrain(r, tsx, cmd);

% 预测
[r_predict,r_mse] = svmpredict(r,tsx,low_model);
r_predict = mapminmax('reverse',r_predict,r_ps);
predict_r = svmpredict(1,win_num+1,r_model);
predict_r = mapminmax('reverse',predict_r,r_ps);
predict_r

%% 对于R的回归预测结果分析
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
title('误差(predicted data-original data)','FontSize',12);
grid on;
snapnow;

%% 利用SVM对Up进行回归预测

% 数据预处理,将up进行归一化处理
% mapminmax为matlab自带的映射函数
[up,up_ps] = mapminmax(Up);
up_ps.ymin = 100;
up_ps.ymax = 500;
% 对Up进行归一化
[up,up_ps] = mapminmax(Up,up_ps);
% 画出Up归一化后的图像
figure;
plot(up,'gx');
title('Up归一化后的图像','FontSize',12);
grid on;
% 对up进行转置,以符合libsvm工具箱的数据格式要求
up = up';
snapnow;

% 选择回归预测分析中最佳的SVM参数c&g
% 首先进行粗略选择
[bestmse,bestc,bestg] = SVMcgForRegress(up,tsx,-10,10,-10,10,3,1,1,0.5);

% 打印粗略选择结果
disp('打印粗略选择结果');
str = sprintf( 'SVM parameters for Up:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% 根据粗略选择的结果图再进行精细选择
[bestmse,bestc,bestg] = SVMcgForRegress(up,tsx,-4,8,-10,10,3,0.5,0.5,0.2);

% 打印精细选择结果
disp('打印精细选择结果');
str = sprintf( 'SVM parameters for Up:Best Cross Validation MSE = %g Best c = %g Best g = %g',bestmse,bestc,bestg);
disp(str);

% 训练SVM
cmd = ['-c ', num2str(bestc), ' -g ', num2str(bestg) , ' -s 3 -p 0.1'];
up_model = svmtrain(up, tsx, cmd);

% 预测
[up_predict,up_mse] = svmpredict(up,tsx,up_model);
up_predict = mapminmax('reverse',up_predict,up_ps);
predict_up = svmpredict(1,win_num+1,up_model);
predict_up = mapminmax('reverse',predict_up,up_ps);
predict_up

%% 对于Up的回归预测结果分析
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
title('误差(predicted data-original data)','FontSize',12);
grid on;
toc;
snapnow;
