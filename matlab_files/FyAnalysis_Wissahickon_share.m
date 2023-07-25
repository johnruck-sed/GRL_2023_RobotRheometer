function k = FyAnalysis_Wissahickon_share(time,Fy,intrusionstarttime,intrusionendtime,Fyfilter)
%function k = FyAnalysis_Wissahickon_share(h,pu,intrusionstarttime,intrusionendtime,Fyfilter)

% this function analyzes vertical intrusion force
% input:
%   startypos: initial y pos of toe above surface (cm)
%   hitGNDtimeMin,hitGNDtimeMax: minimal and maximal possible time for leg to hit surface
% output:
%   k: slope of vertical intrusion force vs. depth
%   d_actual: actual intrusion depth averaged through the entire intrusion range

    intrusionstartind=find(time>intrusionstarttime,1);
    intrusionendind=find(time>intrusionendtime,1);
%     shearendind=find(time>shearendtime,1);
    
%     d1_actual=-(y_actual(intrusionendind)-y_actual(intrusionstartind))*100 - startypos; %cm, from startypos=2cm above surface
%     d2_actual=-(y_actual(shearendind)-y_actual(intrusionstartind))*100 - startypos; %cm, from startypos=2cm above surface
%     d_actual=-(mean(y_actual(shearstartind:shearendind))-y_actual(intrusionstartind))*100-startypos; %cm, averaged through the shear range
%         
    % Fy/d for surface intrusion (k1)
    dFy_unfiltered=diff(Fy);
    dFy=butterfilter(diff(Fy),Fyfilter,5);   

    % search for the start of intrusion force increase (maximal derivative)
    hitGNDtimeMin = intrusionstarttime + 4 - 0.5;
    hitGNDtimeMax = intrusionstarttime + 4 - 0.5;
    
    searchstart=find(time>hitGNDtimeMin,1);
    searchend=find(time>hitGNDtimeMax,1);
    peakpos = find(dFy==max(dFy(searchstart:searchend)));
    hitGNDtime = time(peakpos)-0.4; %s
    
    %     % Fy/d for entire intrusion range (k)    
    fitstart=find(time>hitGNDtime,1);  
    fitend=find(time>intrusionendtime,1);
    ky_all(1:2)=polyfit(time(fitstart:fitend),Fy(fitstart:fitend),1);
    k=ky_all(1);
    Fyfit_all=polyval(ky_all,time(fitstart:fitend));
    
    figure(4);hold on;
%     plot(time,Fy,'r-','linewidth',2);
    plot(time(fitstart:fitend),Fyfit_all,'k--','linewidth',1);
%     xlim([1 9]);
%     pause(2);
    %figure(6);hold on;
    %plot(z(fitstart:fitend), Fyfit_all, 'k--', 'linewidth',1);
    figure(7);hold on;
    plot(time(fitstart:fitend),Fyfit_all,'k--','linewidth',1);
end