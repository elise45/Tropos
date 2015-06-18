function [k_T, numS, T] = cumulative_spectrum(numSamples,datasSamples,info_num,graph_cum)

%numSamples = [1];%[217 218 216];
%datasSamples = xlsread('datas_lab_IN.xlsx');
%[info_num, info_text, info_all] = xlsread('PANGAEA-longterm.xlsx');
%graph_cum=1;

%% Re-arranging the vector numSamples, if necessary
if numSamples(1)==1, numS = nan(1,length(datasSamples)/3 -1); j=1;
    for k=1:3:length(datasSamples)-1, if datasSamples(1,k)>1, numS(j) = datasSamples(1,k); j=j+1; end; end
end
if sum(numSamples)<0, for k=2:length(numSamples), numS(find(numS==abs(numSamples(k))))=[]; end
end

if numSamples(1)>1 && sum(numSamples)>0, numS = numSamples; end

L = length(numS);

%% Initializating variables

T = nan(length(datasSamples(:,1))-2,L);
nb_frz = nan(length(datasSamples(:,1))-2,L);
cum_frz = nan(length(datasSamples(:,1))-2,L);
k_T = nan(length(datasSamples(:,1))-2,L);


%% Affecting values to the variables
for s=1:L
    col = [find(datasSamples(1,:)==numS(s)) find(datasSamples(1,:)==numS(s))+1];
    T(:,s) = datasSamples(3:end,col(1));
    nb_frz(:,s) = datasSamples(3:end,col(2));
    cum_frz(:,s) = cumsum(nb_frz(:,s));
    
    volume = (info_num(find(info_num(:,1)==numS(s)),10)) / 140^2;
    nb_unfrz = 103-cum_frz(:,find(numS==numS(s)));
    k_T(:,s) = (1./volume).*log(103./nb_unfrz);
end

% Remove "inf"
k_T(isinf(k_T))=nan;

% Variable water
lines_water = abs(isnan([datasSamples(3:end,find(datasSamples(1,:)==0)) datasSamples(3:end,find(datasSamples(1,:)==0)+1)])-1);
datas_water = [datasSamples(3:end,find(datasSamples(1,:)==0)) datasSamples(3:end,find(datasSamples(1,:)==0)+1)]; r=1;

for w=1:length(datas_water), if isnan(datas_water(w,1)), W(r)=w; r=r+1; end, end
datas_water(W,:)=[];
T_water = datas_water(:,1);
cum_water = cumsum(datas_water(:,2));
vol_water = 30*72/(140^2);
k_T_water = (1./vol_water).*log(103./(103-cum_water));
    for k=1:length(k_T_water), 
        if isinf(k_T_water(k)), k_T_water(k)=[]; T_water(k)=[]; k=k-1; 
        end
    end


%% Graphic
if graph_cum==1

% Graph variables
if length(graph_cum)==1
    graph_cum=ones(1,L);
    %color = hsv(L);
    
    filter_infos = xlsread('infos_filtres.xlsx');
    colorb = [
        135, 206, 250;
        255, 255, 254;
        250, 235, 215;
        245, 222, 179;
        210, 180, 140;
        205, 133, 63;
        153, 76, 0;
        122, 51, 0;
          ]/255;
end

% Plot water
h = area(T_water,k_T_water,'HandleVisibility','off');
set(h,'FaceColor',[0.9 0.95 1],'EdgeColor',[0.9 0.95 1]);


% Plot k_T vs T
for i=1:length(numS)
    hold on
    if graph_cum(i)==1,
        teinte = filter_infos(find(filter_infos(:,1)==numS(i)),2);
        color = colorb(teinte-1,:);
        plot(T(:,i),k_T(:,i),'.','color',color);
        plot(T(:,i),k_T(:,i),':','color',color,'HandleVisibility','off');
        legendInfo{i} = num2str(numS(i));
    end
end

% Graph settings
xlabel('Temperature [^{o}C]')
ylabel('Cumulative spectrum')
legend(legendInfo)
end