clear all; close all;
clc
%%%%%%%%%%%%%%% CHANGE PATH TO WHERE CODE IS STORED %%%%%%%%%%%%%%%%%%%%
cd 'C:\Users\johng\Downloads\matlabfiles\';
%%%%%%%%%%%%%%% CHANGE PATH TO WHERE DATA IS STORED %%%%%%%%%%%%%%%%%%%%
dirname=['C:\Users\johng\Downloads\matlabfiles\RobotTest\VolumeFrac_Trial_057\'];
%file = 'C:\Users\johng\Downloads\matlabfiles\DataFiles\';

% parameters (CHANGE IF DIFFERENT)
v=0.01; %m/s
toe_extension = 0.095;%0.08; % for metal square rod toe tip (20190626)
% toe_extension = 0.06; % for Minitaur rubber toe
startypos = 0.02; %m, initial y position above surface

%% Load all data files
filenamelist=0;clear filenamelist;
ddtop=dir(dirname);
count=1;
for jj=3:size(ddtop,1)
    filenametmp=strcat(dirname,ddtop(jj).name);
    filenamelist(count)={filenametmp};
    fnameintmp=ddtop(jj).name;
    namelist(count)={fnameintmp};
    
    %%%%%%%%%%%%%%%%%% CHANGE BASED ON THE FILENAME SCHEME %%%%%%%%%%%%%%%
    i1=findstr('V',fnameintmp)+1;
    p = fnameintmp(i1);
    loc (count)= str2num(fnameintmp(i1));
    p1=loc (count);
    i2=findstr('S',fnameintmp)+1;
    samplenum (count)=str2num(fnameintmp(i2));

    
    count=count+1;
end
lff=length(filenamelist);
color=cool(lff);

% verticalind=find(protocol=='V');
% horizontalind=find(protocol=='H');

%% plot data (obtained by Arduino)
count=1;
%mu=zeros(1860,lff);
for jj=1:lff

    [time,x_des,y_des,x_actual,y_actual,Fx,Fy]=LoadShearData_Wissahickon_202007_arduino_share(char(filenamelist(jj)),toe_extension);
% [time,x_des,y_des,x_actual,y_actual,Fx,Fy]=LoadShearData_Wissahickon_20180717_header_tail(file,toe_extension);
   % offset toe weight by subtracting the force when leg is hanging in the air
    l=size(time);

    offsetstartind=find(time>0,1);
    offsetendind=find(time>0.1,1);
    FxOffset = mean(Fx(offsetstartind:offsetendind));
    FyOffset = mean(Fy(offsetstartind:offsetendind));
    Fx = -(Fx - FxOffset);
    Fy = -(Fy - FyOffset);
    z = v*time;
    
    nu = abs(Fx/Fy);
    mu=nu(nu~=0);
    
    z_norm = (z - min(z)) / (max(z) - min(z));
    mu_norm = (mu - min(mu)) / (max(mu) - min(mu));

    num = 25;
    coeff50 = ones(1, num)/num;
    smooth = filter(coeff50, 1, mu);

    %leg starts 2 cm above surface
    y_actual_fromsurf = -(y_actual-y_actual(1))+startypos;
    y_des_fromsurf = -(y_des-y_des(1))+startypos;

    %%%%%%%%normalizing attempts
    %pressure (Pz = Fz / A)
    A = 0.00016129; %for lab intruders
    A_f = 0.00005041; %for field intruders

    pz = -Fy / A; %lab
    pz_f = -Fy / A_f; %field

    %nondimensionalizing (Pu = Pz / (pb)(g)(Re)
    pb_57 = 2500 * 0.57;
    pb_59 = 2500 * 0.59
    g = 9.8;
    Re = 0.00635;

    pu_57 = pz / (pb_57 * g * Re);
    pu_59 = pz / (pb_59 * g * Re);

    %depth (h = z / Re)
    Re = 0.00635;

    h = z / 0.007167;
    %%%%%%%%%%%

% linear fit attempt
    
    

% plot actual position 
    %figure(2); box on;hold all;
    %plot(time,x_actual,'color',color(jj,1:3),'linewidth',2);hold on;
    %plot(time,-y_actual,'color',color(jj,1:3),'linewidth',2,...
        %'DisplayName',sprintf('loc %d, %d',loc(jj), samplenum(jj)));hold on;
    
% plot desired position 
    %plot(time,x_des,'r--','linewidth',2);hold on;
    %plot(time,-y_des,'k--','linewidth',1.5);hold on;


% plot vertical force 
   figure(4);hold all;box on;
   hy3(jj)=plot(time,-Fy,'color',color(jj,:),'linewidth',1,...
              'DisplayName',sprintf('loc%d, %d',loc(jj), samplenum(jj)));hold on;
   % hy3(count)=plot(time,Fy,'color',color(jj,:),'linewidth',2,...
   %            'DisplayName',sprintf(' %d.%d',loc(jj),pts(jj)));hold on;
   xlim([1, 8.5]);
   
   %c = colorbar;
   %c.Label.String = 'horizontal distance downslope (m)'

   % plot vertical force vs distance
   figure(6);hold all;box on;
   hy3(jj)=plot(z,-Fy,'color',color(jj,:),'linewidth',1,...
              'DisplayName',sprintf('loc%d, %d',loc(jj), samplenum(jj)));hold on;
   %hy3(count)=plot(z,Fy,'color',color(jj,:),'linewidth',2,...
              %'DisplayName',sprintf(' %d.%d',loc(jj),pts(jj)));hold on;
   xlim([0.01, 0.08]);
   %ylim([0,8]);

   %plot dimensionless pressure vs. depth
   figure(7);hold all;box on;
   %plot(h, pu_57);
   %plot(h, pu_59);
   hy3(jj)=plot(h,pu_57,'color',color(jj,:),'linewidth',1,...
              'DisplayName',sprintf('loc%d, %d',loc(jj), samplenum(jj)));hold on;
   xlim([1, 11]);
   ylim([0, 700]);


   %plot field data pressure (Pz) against depth (h)
   figure(8);hold all;box on;
   %plot(z, pz_f);
   hy3(jj)=plot(z,pz,'color',color(jj,:),'linewidth',1,...
              'DisplayName',sprintf('loc%d, %d',loc(jj), samplenum(jj)));hold on;
   xlim([0.01, 0.08]);
   ylim([0, 50000]);

   %% vertical intruision force analysis

    intrusionstarttime=1; %s  %% CHANGE IF DIFFERENT
    intrusionendtime=8; %s  %% CHANGE IF DIFFERENT
    Fyfilter = 70;
    stiffness(jj) = FyAnalysis_Wissahickon_share(time,-Fy,intrusionstarttime,intrusionendtime,Fyfilter);

end
%figure(2);hold on;xlabel('time (s)','fontsize',14);ylabel('position (m)','fontsize',14);
%set(gca,'fontsize',14);set(gcf,'color','w');
figure(4);hold on;xlabel('Time (s)','fontsize',14);ylabel('Normal Force (N)','fontsize',14);
set(gca,'fontsize',14);set(gcf,'color','w');
legend(hy3);
figure(7);hold on;xlabel('h','fontsize',14);ylabel('pu','fontsize',14);
set(gca,'fontsize',14);set(gcf,'color','w');
legend(hy3);
figure(6);hold on;xlabel('z (m)','fontsize',14);ylabel('Normal Force (N)','fontsize',14);
set(gca,'fontsize',14);set(gcf,'color','w');
figure(8);hold on;xlabel('h (m)','fontsize',14);ylabel('Pz (N/m^2)','fontsize',14);
set(gca,'fontsize',14);set(gcf,'color','w');
legend(hy3);