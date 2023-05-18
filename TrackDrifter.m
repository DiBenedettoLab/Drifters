


function fig=TrackDrifter(IDs,dataset,varargin)
% hf=TrackDrifter(IDs,ds,fignum)
% hf=TrackDrifter(IDs,data2load,fignum)
% IDs: either one ID number or multipl in a vector
% ds: strucutre for faster processing
% data2load: 'spot', 'buoy', or 'both' (need func load_drift_data)
% fignum: number figure to plot on (if empty will create a new figure)

%%% ---------------------------- CONSTANTS ---------------------------- %%%
SliderPos = [0.25 0.05 0.5 0]; % position of time slider, normalized units
ax1pos = [0.05,0.6,0.3,0.35];
IDGroupPos = [0.05,0.1,0.3,0.3];
NormTimeGroupPos = [0.05,0.5,0.3,0.05];
AllGroupPos = [0.05,0.4,0.3,0.05];
ax3pos = [0.4,0.1,0.55,0.85];
justchecked=false;
timenorm=false;

%%% -------------------------- PARSE INPUTS --------------------------- %%%
args=varargin;

% -- dataset -- %
if iscell(dataset) %need to load data
    warning("load in data for faster processing")
    if numel(dataset)==2
        ds=load_drift_data(string(dataset{2}(1)),string(dataset{2}(2)));
    else
       ds=load_drift_data(string(dataset{1}(:)));
    end
else %struct input
    ds=dataset; 
end

% -- PARSE VARARGIN -- %
%turns true if they exist
nofiginput=true;
nobcritinput=true;
notransloninput=true;
adddaysnorm=false;

if numel(args)>0
    %checks that each input has 
    if rem(numel(args),2)
        error('do better (fix this error later)')
    end

    %goes through each input
    for i=1:2:numel(args)
        switch args{i}
            case 'FigNum'
                fignum=args{i+1};
                fig=figure(fignum);clf
                nofiginput=false;
            case 'bcrit'
                bcrit=args{i+1};
                hasbcrit=true;
                nobcritinput=false;
            case 'adjlon'
                if strncmp(args{i+1},'auto',4)
                    warning('tbd')
                elseif strncmp(args{i+1},'none',4) || isempty(args{i+1})
                    translon=false;
                elseif abs(args{i+1})<=180
                    translon_amnt=args{i+1};
                    translon=true;
                else
                    error("if using 'adjlon', enter 'auto' or a number from -180 to +180")
                end
                notransloninput=false;
            otherwise
                error("Valid inputs are: 'FigNum', 'bcrit', or 'LatLonData")
        end %switch args{i}
    end %for i=1:2:numel(args)
end %if numel(args)>0

%if these things are not input defaults to these
if nofiginput
    fig=figure;
    fig.Position=[fig.Position(1) fig.Position(2) 1000 600];
end
if nobcritinput
    hasbcrit=false;
end
if notransloninput
    translon=false;
end

%check if ds has days_norm
if ~ismember('days_norm',fieldnames(ds))
    adddaysnorm=true;   
end

%check if ID part of struct is capital
if ismember('ID',fieldnames(ds))
    for i=1:length(ds)
        ds(i).id=ds(i).ID;
    end
end

%%% ---------------------- FINDING DATA TO PLOT ----------------------- %%%

times=[];

if sum(sum(IDs(:)==[ds(:).id]))==numel(IDs) 
    for i=1:numel(IDs)
        indx(i)=find(IDs(i)==[ds(:).id]); %indices of the ID's

        %not all data has days_norm
        if adddaysnorm
            ds(indx(i)).days_norm = ds(indx(i)).time/86400;
        end

        times=[times;ds(indx(i)).days_norm];
        mintimes4norm(i)=min(ds(indx(i)).days_norm);
        maxtimes4norm(i)=max(ds(indx(i)).days_norm);

        %moves the data over if requested
        if translon
            indx2shift=(ds(indx(i)).lon<=translon_amnt);
            ds(indx(i)).lon(indx2shift)=ds(indx(i)).lon(indx2shift)+360;
        end

        %for bounds of map
        minlatloop(i)=min(ds(indx(i)).lat);
        maxlatloop(i)=max(ds(indx(i)).lat);
        minlonloop(i)=min(ds(indx(i)).lon);
        maxlonloop(i)=max(ds(indx(i)).lon);

        %for bounds of coast
        maxcoasttimeloop(i)=max(ds(indx(i)).days_norm);
        mincoasttimeloop(i)=min(ds(indx(i)).days_norm);
        maxcoastloop(i)=max(ds(indx(i)).coast);
        mincoastloop(i)=min(ds(indx(i)).coast);

        %max t_indx for initial plotting
        t_indx(i)=numel(ds(indx(i)).lon);
    end
else
    error('Error, index not within data')
end

%initializing hide ID's for toggle
showIDs=ones(numel(IDs),1);

%normalized times
timezero=min(times);
times=times-timezero;
maxtime=max(times);
mintime=0;
maxcoasttimeloop=maxcoasttimeloop-timezero;
mincoasttimeloop=mincoasttimeloop-timezero;

%if the user wants each to start at 0
mintimes4norm=mintimes4norm-timezero;
maxtimes4norm=maxtimes4norm-mintimes4norm;

% lat and lon bounds
minlat=min(minlatloop);
maxlat=max(maxlatloop);
minlon=min(minlonloop);
maxlon=max(maxlonloop);

%this is what time it plots up to
timeend=maxtime;

%%% ----------------------- CREATE AXES AND UIS ----------------------- %%%
%creating figure
% mypos=get(fig,'position');
% mypos(3:4)=FigSize;
% set(fig,'position',mypos)%,'name',['t = ' num2str(t(indt),'%0.3f') ' (' num2str(indt) ' of ' num2str(numel(ds.lat)) ')'],'color','w');

TimeSlider = uicontrol('Style','slider','units','normalized', ...
    'Position',SliderPos,'Min',mintime,'Max',maxtime, ...
    'Value',timeend,...
    'Callback',@inputFromTimeSlider);

%button groups
IDGroup = uibuttongroup('units','normalized','position', ...
   IDGroupPos,'visible','on');
NormTimeGroup = uibuttongroup('units','normalized','position', ...
   NormTimeGroupPos,'visible','on');
AllGroup = uibuttongroup('units','normalized','position', ...
   AllGroupPos,'visible','on');

%show all
Allcheck = uicontrol(AllGroup,'Style','checkbox','units','normalized','Position',[0,0,0.5,1], ... 
    'FontWeight','bold','String','SELECT ALL','Value',1,'Callback',@AllToggle);

%Show ID numbers
Textcheck = uicontrol(AllGroup,'Style','checkbox','units','normalized','Position',[0.5,0,0.5,1], ... 
    'FontWeight','bold','String','SHOW IDs','Value',1,'Callback',@TextToggle);

%time toggle
NormTimeOFFButton=uicontrol(NormTimeGroup,'style','radiobutton', ... 
    'units','normalized','position',[0,0,0.5,1],'Fontweight','bold', ...
    'string','REAL TIME','Value',1,'Callback',@TimeToggle);
NormTimeONButton=uicontrol(NormTimeGroup,'style','radiobutton', ... 
    'units','normalized','position',[0.5,0,0.5,1],'Fontweight','bold',...
    'string','START ALL AT 0','Value',0,'Callback',@TimeToggle);


%ID buttons
colors=["#0072BD","#D95319","#EDB120","#7E2F8E","#77AC30","#4DBEEE","#A2142F"];
for k = 1:numel(IDs)
    if rem(k,7)==0
        colorid=7;
    else
        colorid=rem(k,7);
    end

    colnum=4;
    cellwid=1/colnum;
    cellheight=1/ceil(numel(IDs)/colnum);

    checkPos1 = [rem(k-1,colnum)*cellwid, floor((k-1)/colnum)*cellheight, cellwid, cellheight];
    checkButtons{k} = uicontrol(IDGroup,'Style','checkbox','units','normalized', ... 
        'Position',checkPos1,'ForegroundColor',colors(colorid), ...
        'FontWeight','bold','String',num2str(IDs(k)),'Value',1,'Callback',@IDToggle);
end

%%% ------------------------- INITIAL PLOTTING ------------------------ %%%
%%% --- COAST VS. TIME --- %%%
ax1=subplot(221);
ax1.Position = ax1pos;
hold on
grid on
title('COASTAL DISTANCE')
xlim([mintime,maxtime])
for i=1:numel(indx)
    ax1coast(i)=plot(ds(indx(i)).days_norm-timezero,ds(indx(i)).coast,'.-');
end
xlabel('days (normalized)')
ylabel('distance from coast (km)')

%vertical line for where the time is
ax1time=plot(timeend*[1,1],ax1.YLim,'-m');

% dotted line for bcrit
if hasbcrit
    plot(ax1.XLim,bcrit*[1,1],'--k')
end

%%% --- TRAJECTORY --- %%%
ax3=subplot(2,2,[2,4]);
ax3.Position = ax3pos;

for i=1:numel(indx)
    ax2geo(i)=geoplot(ds(indx(i)).lat,ds(indx(i)).lon,'.-');
    ax2txt(i)=text(ds(indx(i)).lat(end),ds(indx(i)).lon(end),num2str(IDs(i)),'FontWeight','bold');
    hold on
end
bord=0.1;
lonbounds=[maxlon+bord*abs(maxlon),minlon-bord*abs(minlon)];
[~,lonboundmin]=min(abs(lonbounds));
[~,lonboundmax]=max(abs(lonbounds));
geolimits([minlat-bord*abs(minlat),maxlat+bord*abs(maxlat)],[lonbounds(lonboundmin),lonbounds(lonboundmax)])
%plots where it beaches
if hasbcrit
    for i=1:numel(indx)
        inbcrit=ds(indx(i)).coast<=bcrit;
        ax2dots(i)=geoplot(ds(indx(i)).lat(inbcrit),ds(indx(i)).lon(inbcrit),'o','MarkerEdgeColor','k','MarkerFaceColor',ax2geo(i).Color);
        hold on
    end
    
end

%%% ----------------------------- CALLBACK ---------------------------- %%%
% -=- Callback: When the user changes time using the slider bar -=-
    function inputFromTimeSlider(~,~)
        timeend=get(TimeSlider,'value');
        for gg=1:numel(indx)
            if isempty(find(timeend>=ds(indx(gg)).days_norm-timezero, 1))
                t_indx(gg)=0; %it is before the data
            else
                t_indx(gg)=find(timeend>=ds(indx(gg)).days_norm-timezero,1,'last'); %finds the last index in time
            end
        end        
        updatePlot();
    end % function inputFromTimeSlider(~,~)

% -=- Callback: When the user selects time norm checkbox -=-
    function TimeToggle(~,~)
        if get(NormTimeONButton,'value') %each starts at 0
            set(NormTimeOFFButton,'value',0)
            if ~timenorm %moving from checked off to on (so it doesnt fuck with time)
                timenorm=true;
                justchecked=true;
                for gg=1:numel(indx)
                    ds(indx(gg)).days_norm=ds(indx(gg)).days_norm-mintimes4norm(gg);
                    set(ax1coast(gg),'XData',ds(indx(gg)).days_norm)
                end
            end
        end
        if get(NormTimeOFFButton,'value') %whole data starts at 0
            set(NormTimeONButton,'value',0)
            if timenorm %moving from checked on to off (so it doesnt fuck with time)
                timenorm=false;
                justchecked=true;
                for gg=1:numel(indx)
                    ds(indx(gg)).days_norm=ds(indx(gg)).days_norm+mintimes4norm(gg);
                    set(ax1coast(gg),'XData',ds(indx(gg)).days_norm)
                end
            end
        end
        updatePlot();
    end % function TimeToggle(~,~)


% -=- Callback: When the user selects ID checkboxes -=-
    function IDToggle(~,~)
        justchecked=true;
        for cc=1:numel(IDs)
            if get(checkButtons{cc},'value')
                showIDs(cc)=true;
            else
                showIDs(cc)=false;
            end
        end
        updatePlot();
        TextToggle();
    end % function OverlayToggle(~,~)

% -=- Callback: when user checks select all -=-
    function AllToggle(~,~)
        justchecked=true;
        if get(Allcheck,'value')
            for gg=1:numel(IDs)
            showIDs(gg)=true;
            set(checkButtons{gg},'Value',1);
            end
        else
            for gg=1:numel(IDs)
            showIDs(gg)=false;
            set(checkButtons{gg},'Value',0);
            end
        end
        showIDs=logical(showIDs);
        updatePlot();
        TextToggle();
    end % function TextToggle(~,~)

% -=- Callback: When the user changes the normalization of time -=-
    function TextToggle(~,~)
        for cc=1:numel(IDs)
            if get(Textcheck,'value')
                showtextIDs=true;
                visibletext='on';
            else
                showtextIDs=false;
                visibletext='off';
            end
        end
        
        %shows text IDs
        for rt=1:numel(indx)
            if showIDs(rt)
                set(ax2txt(rt),'visible',visibletext)
            else
                set(ax2txt(rt),'visible','off')
            end
        end
    end % function TextToggle(~,~)

%%% --------------------------- UPDATE PLOT --------------------------- %%%
    function updatePlot(~)

        %if things were just unchecked or checked
        if justchecked
            justchecked=false;
            %hides coast info
            for hh=1:numel(IDs)
                if showIDs(hh)
                    set(ax1coast(hh),'Visible','on')
                    set(ax2geo(hh),'visible','on')
                    if hasbcrit
                    set(ax2dots(hh),'visible','on')
                    end
                else
                    set(ax1coast(hh),'Visible','off')
                    set(ax2geo(hh),'visible','off')
                    if hasbcrit
                    set(ax2dots(hh),'visible','off')
                    end
                end
            end

            if sum(showIDs)~=0
            %changes geoplot limits
            minlat=min(minlatloop(logical(showIDs)));
            maxlat=max(maxlatloop(logical(showIDs)));
            minlon=min(minlonloop(logical(showIDs)));
            maxlon=max(maxlonloop(logical(showIDs)));
            
%             set(fig,'currentaxes',ax3)
            lonbounds=[maxlon+bord*abs(maxlon),minlon-bord*abs(minlon)];
            [~,lonboundmin]=min(abs(lonbounds));
            [~,lonboundmax]=max(abs(lonbounds));
            geolimits([minlat-bord*abs(minlat),maxlat+bord*abs(maxlat)],[lonbounds(lonboundmin),lonbounds(lonboundmax)])

            %changing view of coast axis
            %x axis
            if timenorm
                mintime4ax=0;
                maxtime4ax=max(maxtimes4norm(showIDs));
            else
                mintimetemp=mincoasttimeloop;
                mintimetemp(~logical(showIDs))=[];
                maxtimetemp=maxcoasttimeloop;
                maxtimetemp(~logical(showIDs))=[];
                mintime4ax=min(mintimetemp);
                maxtime4ax=max(maxtimetemp);
            end


            ax1.XLim=[mintime4ax,maxtime4ax];
            if TimeSlider.Value>ax1.XLim(2)
                TimeSlider.Value=ax1.XLim(2);
            end
            if TimeSlider.Value<ax1.XLim(1)
                TimeSlider.Value=ax1.XLim(1);
            end
            TimeSlider.Min=ax1.XLim(1);
            TimeSlider.Max=ax1.XLim(2);
            %y axis
            mincoasttemp=mincoastloop;
            mincoasttemp(~logical(showIDs))=[];
            maxcoasttemp=maxcoastloop;
            maxcoasttemp(~logical(showIDs))=[];
            ax1.YLim=[min(mincoasttemp),max(maxcoasttemp)];
            end %sum(showIDs)~=0

        end %justchecked

        %pink line on coast
        set(ax1time,'XData',timeend*[1,1],'YData',ax1.YLim)
        % set(ax2time,'XData',timeend*[1,1])

        %replots trajectories
        for rt=1:numel(indx)
            if showIDs(rt)
                set(ax2geo(rt),'visible','on')
                set(ax2geo(rt),'LatitudeData',ds(indx(rt)).lat(1:t_indx(rt)),'LongitudeData',ds(indx(rt)).lon(1:t_indx(rt)))
            else
                set(ax2geo(rt),'visible','off')
            end
        end % rt=1:numel(indx)
    end % function updateImagesAndQuivers(~)
end %whole things


