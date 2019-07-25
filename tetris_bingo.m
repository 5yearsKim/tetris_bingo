function Bingo()
global main;
main = figure('numbertitle','off','toolbar','none','menubar','none','color','black','name','Bingo','resize','off');
 
% 장애물이 몇번 펀치를 맞는지 셈.
global push_cnt;
push_cnt = 0;
 
global now_cnt;
now_cnt= 0;
 
% mode 0일때 set_mode  mode 1 일때 shakehand, 게임실행.
global mode;
mode = 0;
 
global bingoCnt;
bingoCnt = 0;
 
%빙고 pushbutton 선택 여부 저장
global bingo_mat;
bingo_mat = zeros(5,5);
 
%아이템 사용 여부 저장
global item_used;
item_used = false;
 
 
global u;
u = udp('172.20.219.23','remoteport',8899,'localport',4478);
 
handles.start_btn = uicontrol('parent',main,'tag','start_btn','style','pushbutton','string','START!','fontsize',14,'fontweight','bold','backgroundcolor',[1 1 0],'position',[260 20 140 45],'enable','off','visible','off');
handles.cnt_box_me = uicontrol('parent',main,'tag','cnt_box_me','style','text','string','0','position',[400 20 75 50],'fontsize',30);
handles.cnt_box_opp = uicontrol('parent',main,'tag','cnt_box_opp','style','text','string','0','position',[475 20 75 50],'fontsize',30);
handles.label_box_me = uicontrol('parent',main,'tag','label_box_me','style','text','string','내 빙고','position',[400 70 75 25],'fontsize',13,'backgroundcolor',[1 0.5 0.5],'foregroundcolor',[1 1 1]);
handles.label_box_opp = uicontrol('parent',main,'tag','label_box_opp','style','text','string','상대 빙고','position',[475 70 75 25],'fontsize',13,'backgroundcolor',[1 0.8 0.5],'foregroundcolor',[1 1 1]);
handles.random_btn = uicontrol('parent',main,'tag','random_btn','style','pushbutton','string','랜덤 배치','backgroundcolor',[0 1 0],'position',[10 10 100 50]);
handles.exit_btn = uicontrol('parent',main,'tag','exit_btn','style','pushbutton','string','X','position',[520 400 30 20]);
handles.turn_sign = uicontrol('parent',main,'tag','turn_sign','style','text','string','','position',[370 110 180 80],'fontsize',30,'backgroundcolor',[0 0 0],'fontweight','bold');
handles.opp_now = uicontrol('parent',main,'tag','opp_now','style','text','string','상대방 빙고','position',[400 375 150 20],'fontsize',13,'backgroundcolor',[1 1 0],'fontweight','bold');
handles.item_frame2 = uicontrol('parent',main,'style','frame','tag','frame2','position',[25 95 315 315],'backgroundcolor','black');
handles.item_frame = uicontrol('parent',main,'style','frame','position',[135 10 120 50],'backgroundcolor',[1 0.8 0.4]);
handles.item_barrier = uicontrol('parent',main,'style','pushbutton','tag','item_barrier','position',[140 15 50 40],'string','장님','backgroundcolor',[1 0.3 0.3],'enable','off','foregroundcolor','yellow','fontweight','bold');
handles.item_onemore = uicontrol('parent',main,'style','pushbutton','tag','onemore','position',[200 15 50 40],'string','한번더','backgroundcolor',[1 0.3 0.3],'enable','off','foregroundcolor','yellow','fontweight','bold');
handles.item_label = uicontrol('parent',main,'style','text','string','아이템','position',[140 63 200 12],'backgroundcolor','black','foregroundcolor','white','horizontalalignment','left');
 
%barrier아이템 설정
set(handles.item_barrier,'callback',{@show_barrier});
%onemore 아이템 설정
set(findobj(main,'tag','onemore'),'callback',@MyTurn);
 
%내 빙고 btn 25개 생성
for i=1:1:25
    pos_x = 35.+60.*(floor((i-1)/5));
    pos_y = 345-60.*mod(i-1,5);
    obj = uicontrol('parent',main,'tag',int2str(i),'style','pushbutton','position',[pos_x pos_y 53 53],'fontsize',18,'userdata',[0 0]);
    set(obj,'callback',{@press_btn,handles,i});
end
 
%상대방 빙고 btn 25개 생성
for i=1:1:25
    pos_x = 400.+30.*(floor((i-1)/5));
    pos_y = 340-30.*mod(i-1,5);
    obj = uicontrol('parent',main,'tag',strcat('opp_',int2str(i)),'style','pushbutton','position',[pos_x pos_y 28 28],'userdata',[0 0],'enable','off');
end
 
 
handles.win_lost = uicontrol('parent',main,'tag','win_lost','style','text','string','짐ㅋ','position',[30 100 400 300],'fontsize',140,'backgroundcolor',[1 1 1],'fontweight','bold','visible','off');
set(handles.random_btn,'callback',{@random_pick,handles});
set(handles.start_btn,'callback',{@shakehand,handles});
set(handles.exit_btn,'callback',{@exitevent});
end
 
function win_bgm()
    [y,Fs] = audioread('youwin.wav');
    sound(y,Fs);
end
 
function lost_bgm()
    [y,Fs] = audioread('youlose.wav');
    sound(y,Fs);
end
 
function game_bgm()
    [y,Fs] = audioread('게임BGM.mp3');
    sound(y,Fs);
end
 
%아이템 누르면 실행, udp로 barrier 전송.(case 3)
function show_barrier(obj,event)
    global item_used;
global u;
    fwrite(u,3); 
    item_used = true;
end
 
%exit btn callback
function exitevent(obj,event)
    global u;
    fclose(u);
    close ALL
end
 
%start_btn Callback 함수. bingo game 시작, tetris figure 생성, 게임 bgm 재생.
function shakehand(obj,event,handles)
    global u;
    global main
    fopen(u);
    set(u,'DatagramReceivedFcn',{@getParam_0});
    set(obj,'enable','off');
    fprintf(u,'shaked');
    set(obj,'string','게임 진행중');
    set(findobj(main,'tag','frame2'),'backgroundcolor',[1 1 0.5])
    set(findobj(main,'tag','turn_sign'),'string','즐겜~','fontsize',30,'foregroundcolor',[1 1 0])
    tetris();
    game_bgm();
end
 
%bingo button들의 Callback 함수. setmode 전에 random모드가 실행되지 않을 경우(case 0) 누르는 순서대로 숫자 지정.
%숫자가 다 지정된 경우(setmode실행, case 1) select_btn 함수로 인수 이동
function press_btn( obj,event, handles,index)
    global main;
    global now_cnt;
    global mode;
    switch(mode)
        case 0
            userdata = get(obj,'userdata');
            if(userdata(1) == 0)
                now_cnt = now_cnt+1;
                num = now_cnt;
                userdata(1) = num;
                set(obj,'string',num,'userdata',userdata);
                if(now_cnt == 25)
                    setmode(1,handles);
                end
            elseif(userdata(1) == now_cnt)
                now_cnt = now_cnt-1;
                userdata(1) = 0;
                set(obj,'string','','userdata',userdata);
            end
        case 1
            select_btn(obj,'me',index);
    end
end
 
% 숫자가 다 정해진 상태. start_btn이 나타남. 준비완료 string 설정. 빙고 enable off.
function setmode(mode_0,handles)
    global mode;
    global main;
    mode = mode_0;
    parent = main;
    for i=1:1:25
        objj = findobj(parent,'tag',int2str(i));
        set(objj,'enable','off')
    end
    set(handles.start_btn,'enable','on','visible','on');
    set(findobj(parent,'tag','random_btn'),'backgroundcolor',[1 1 0],'string','준비완료','fontsize',15,'fontweight','bold');
end
 
%내가 누른 경우(case 'me') 청록색 색깔 바뀜, udp로 숫자 전송(sendNum), 누른 후 enable off
%상대가 누른 경우(case 'opp')datarecieve로 받아옴. 색깔 초록색으로 설정
function select_btn(obj,type,index)
    global bingo_mat;
    global main;
    global nextTurn;
    parent = get(obj,'parent');
    userdata = get(obj,'userdata');
    if(userdata(2) == 0)
        userdata(2) = 1;
        set(obj,'userdata',userdata);
        bingo_mat(mod(index-1,5)+1,floor((index-1)/5)+1) = 1;
        switch(type)
            case 'me'
                set(obj,'backgroundcolor',[0.4 0.9 1]);
                sendNum(obj,str2num(get(obj,'string')));
                if(nextTurn ~= 1)
                    set(findobj(main,'tag','turn_sign'),'string','Hurry up!', 'fontsize',30,'fontweight','bold','foregroundcolor',[1 1 0] );                    
         set(findobj(main,'tag','frame2'),'backgroundcolor',[0 0 0]);
                    for i=1:1:25
                        objj = findobj(parent,'tag',int2str(i));
                        set(objj,'enable','off');
                    end
                elseif(nextTurn == 1)
                    nextTurn = 0;
                end
            case 'opp'
                set(findobj(main,'tag','frame2'),'backgroundcolor',[0 0 0]);
                set(obj,'backgroundcolor',[0.3 1 0.6]);
                if(nextTurn ~= -1)
                    set(findobj(main,'tag','turn_sign'),'string','고자라니!!','fontweight','bold','foregroundcolor',[1 1 0],'fontsize',20);
                    for i=1:1:25
                        objj = findobj(parent,'tag',int2str(i));
                        set(objj,'enable','off');
                    end
                elseif(nextTurn == -1)
                    nextTurn = 0;
                end
        end
        checkBingo(obj,index);
    end
end
 
%빙고 여부 체크
function checkBingo(obj,index)
    parent = get(obj,'parent');
    global bingoCnt;
    global bingo_mat;
    now_row = mod(index-1,5)+1;
    now_col = floor((index-1)/5)+1;
    % 가로 검사
    if(sum(bingo_mat(now_row:5:25)) == 5)
        for j=now_row:5:25
                set(findobj(parent,'tag',int2str(j)),'backgroundcolor',[1 0 0],'enable','off');
        end
        
            bingoCnt = bingoCnt + 1;
            
    end
    % 세로 검사
    if(sum(bingo_mat(5*now_col-4:1:5*now_col)) == 5)
        for j=5*now_col-4:1:5*now_col
            set(findobj(parent,'tag',int2str(j)),'backgroundcolor',[1 0 0],'enable','off');
        end
       
            bingoCnt = bingoCnt + 1;
        
    end
    % 대각선 검사 1
    if((now_row == now_col) & (sum(bingo_mat(1:6:25)) == 5))
        for j=1:6:25
            set(findobj(parent,'tag',int2str(j)),'backgroundcolor',[1 0 0],'enable','off');
        end
      
            bingoCnt = bingoCnt + 1;
        
    end
    % 대각선 검사 2
    if((now_row + now_col == 6) & (sum(bingo_mat(5:4:24)) == 5))
        for j=5:4:24
            set(findobj(parent,'tag',int2str(j)),'backgroundcolor',[1 0 0],'enable','off');
        end
            bingoCnt = bingoCnt + 1;
        
    end
    set(findobj(parent,'tag','cnt_box_me'),'string',int2str(bingoCnt));
    sendBingo(bingoCnt);
    if(bingoCnt==3)
        won();
    end
end
 
%이겼을때 이김 메세지, 이김 bgm
function won()
    global fig;
    global main;
    set(findobj(main,'tag','turn_sign'),'string','YOU WIN!');
    set(findobj(main,'tag','win_lost'),'visible','on','string','이김ㅋ');
    win_bgm();
end
%졌을때 
function lost()
    global main;
    global u;
    set(findobj(main,'tag','turn_sign'),'string','YOU LOST!');
     set(findobj(main,'tag','win_lost'),'visible','on');
    lost_bgm();
     fclose(u);
end
 
%내 빙고 개수 상대방한테 보내는 함수
function sendBingo(cnt)
    global u;
    fwrite(u,[2 cnt]);
end
 
%내가 클릭한 숫자 상대에게 udp로 보내는 함수
function sendNum(obj,num)
    global u;
    fwrite(u,[1 num str2num(get(obj,'tag'))]);
    showItem(false);
end
 
%아이템의 enable을 켜고 끔
function showItem(b)
    global main;
    global item_used;
    if(b & ~item_used)
        set(findobj(main,'tag','item_barrier'),'enable','on');
        set(findobj(main,'tag','onemore'),'enable','on');
    else
        set(findobj(main,'tag','item_bomb'),'enable','off');
        set(findobj(main,'tag','onemore'),'enable','off');
    end
end
 
 
%내가 버튼을 누를 수 있게 만드는 함수
function MyTurn(hobject,eventdata)
global main;
    for i=1:1:25
            objj = findobj(main,'tag',int2str(i));
            set(objj,'enable','on')
    end
         set(findobj(main,'tag','turn_sign'),'string','My Turn!','foregroundcolor',[0.7 0.9 1]);
         set(findobj(main,'tag','frame2'),'backgroundcolor',[1 1 0.5])
end
 
%모든 경우에서 udp 받을 때 함수 설정, shaked일때, 즉 처음 시작했을 때 bingo 킴.
%shaked_2일때 아이템 on
function getParam_0(udp,event)
    global main;
    global u;
    msg = fscanf(udp,'%s');
    if(strcmp(msg,'shaked') == 1)
        for i=1:1:25
            objj = findobj(main,'tag',int2str(i));
            set(objj,'enable','on')
        end
        set(udp,'DatagramReceivedFcn',{@getParam})
        fprintf(u,'shaked_2');
        set(findobj(main,'tag','start_btn'),'string','드랍각?');
        set(findobj(main,'tag','turn_sign'),'string','My Turn');
        showItem(true);
    elseif(strcmp(msg,'shaked_2') == 1)
        set(udp,'DatagramReceivedFcn',{@getParam})
        set(findobj(main,'tag','start_btn'),'string','치킨먹고싶다');
        set(findobj(main,'tag','turn_sign'),'string','Enemy Turn');
        showItem(true);
    end
end
 
%상대방이 보낸 udp 받는 함수. case 1일때 상대방이 누른 빙고 받아서 내 빙고,상대빙고 색깔 바꿈
%case 2일때 상대방 빙고 갯수 받아옴
%case 3 일때 barrier 생성.
function getParam(udp,event)
    global main;
    msg = fread(udp);
    switch(msg(1))
        case 1
            if(msg(2) ~= 0)
                objj = findobj(main,'string',int2str(msg(2)),'-and','style','pushbutton');
                select_btn(objj,'opp',str2num(get(objj,'tag')));
                fwrite(udp,[1 0 str2num(get(objj,'tag'))]);
            end
            objjj = findobj(main,'tag',strcat('opp_',int2str(msg(3))));
            showItem(true);
            if(get(objjj,'backgroundcolor') ~= [0.8 0.8 0.8])
                set(objjj,'backgroundcolor',[0 0 0]);
            else
                set(objjj,'backgroundcolor',[0.5 0.5 0.5]);
            end
        case 2
            cnt = msg(2);
            set(findobj(main,'tag','cnt_box_opp'),'string',int2str(cnt));
            if(cnt == 3)
                lost();
            end
        case 3
           makebarrier();
    end
end
 
%random btn을 누르면 실행. 빙고 string을 1부터 25까지 랜덤하게 배치해줌. 이후 setmode 함수 실행.
function random_pick(obj,event,handles)
    global now_cnt;
    global mode;
    if(mode == 0)
        parent = get(obj,'parent');
        randarr = randperm(25);
        now_cnt = 0;
        %랜덤한 숫자 생성후 설정
        for i=1:1:25
            objj = findobj(parent,'tag',int2str(i));
            userdata = get(objj,'userdata');
            now_index = randarr(i);
            now_cnt = now_cnt+1;
            userdata(1) = now_index;
            set(objj,'string',now_index,'userdata',userdata);
            if(now_cnt == 25)
                setmode(1,handles);
            end
        end
    end
end
 
%테트리스 함수
function tetris()
    % --------------------------------------------
    % TETRIS - by Jan de Gier, 2011
    % --------------------------------------------
    
    clc;
    % gameplay
    W = 10; H = 20;   % field size - need to be even
    level = 0;        % default = 0, choose in [-3:3]
    randomrows = 0;   % number of randomly filled rows
    invspeed = 200;   % waiting time
    
    counter = 0; move = 0; speedup = 0; paused = 0;
    score = 0; lines = 0;
    play = 1; action = 1; pauseremove = 0.00;
 
    % init figure
    global fig
    scrcenter = get(0,'ScreenSize')/2;
    fig = figure('KeyPressFcn',@Key_Down,'pos',[scrcenter(3)-14.5*W scrcenter(4)-13*H 24+29*W 48+26*H],'menubar','none','numbertitle','off','resize','off','color','black');
    
handles.barrier = uicontrol('parent',fig,'tag','barrier','style','text','string','눌러!','fontsize',30,'foregroundcolor',[0 0 1],'position',[80 90 160 400],'backgroundcolor',[1 0 0.3],'visible','off');
handles.pushpush = uicontrol('parent',fig,'tag','pushpush','style','pushbutton','string','약오르겠다','backgroundcolor',[0.3 0.3 1],'fontsize',15,'fontweight','bold','position',[100,130,140 80],'visible','off', 'Callback',@escape_barrier)
    set(gca,'Fontsize',15)
    title(strcat('score: ',int2str(score)))
    set(gca,'XTick',[],'YTick',[])
    axis([0 W+1 0 H+1])
    % init field and figure
    field = [floor(2*rand(randomrows,W));zeros(H-randomrows,W)];
    [block or] = createblock(H,W,level);
    % start
    while play == 1
        figure(fig)
        % keep focus on figure
        title(strcat('score: ',int2str(score)))
        drawnow
        % check if the figure is closed
        if ~ishandle(fig) 
            close all
            play = -1;
        end
        if paused == 0
            counter = counter+1;
        end
        % check for full rows
        remove = find(sum(field,2) == W);
        if numel(remove) > 0
            lines = lines + numel(remove);           
            for i=numel(remove):-1:1
                index = remove(i);
                [k,j]= find(field);
                hold on
                plot(j,k,'s','MarkerSize',18,'MarkerEdgeColor','k','MarkerFaceColor','b')
                plot(1:W,index,'s','MarkerSize',18,'MarkerEdgeColor','k','MarkerFaceColor','g')
                axis([0 W+1 0 H+1])
                set(gca,'XTick',[],'YTick',[])
                title(strcat('score: ',int2str(score)))
                drawnow
                pause(pauseremove)
                hold off
            end
            for i=numel(remove):-1:1
                score = score + 10*i;
                index = remove(i);
                field = [field(1:index-1,:) ; field(index+1:H,:) ; zeros(1,W)];
            end
            action = 1;
            MyTurn()
            %MyTurn 함수 실행, 한줄이 완성되면 빙고 누를 기회 부여
        end
        % move to the right
        if move == 1 && sum(block(:,W+3,or)) == 0 && paused == 0
            blocktry = [zeros(H+6,1,4),block(:,1:W+5,:)];
            % update block if try hits nothing
            if max(max(blocktry(4:H+3,4:W+3,or)+field)) < 2
                block = blocktry;
            end           
            action = 1;
        end
        % move to the left
        if move == -1 && sum(block(:,4,or)) == 0 && paused == 0
            blocktry = [block(:,2:W+6,:),zeros(H+6,1,4)];
            % update block if try hits nothing
            if max(max(blocktry(4:H+3,4:W+3,or)+field)) < 2
                block = blocktry;
            end            
            action = 1;
        end
        % rotate 
        if abs(move) == 2 && paused == 0
            if move == 2 % rotate counter clockwise
                ortry = or - 1; if ortry == 0, ortry = 4; end
            else % move == -2 % rotate clockwise
                ortry = or + 1; if ortry == 5, ortry = 1; end
            end
            blocktry = block;
            % move tryblock into field
            while sum(blocktry(3,:,ortry)) ~= 0, blocktry = [zeros(1,W+6,4);blocktry(1:H+5,:,:)]; end
            while sum(blocktry(H+4,:,ortry)) ~= 0, blocktry = [blocktry(2:H+6,:,:);zeros(1,W+6,4)]; end
            while sum(blocktry(:,3,ortry)) ~= 0, blocktry = [zeros(H+6,1,4),blocktry(:,1:W+5,:)]; end
            while sum(blocktry(:,W+4,ortry)) ~= 0, blocktry = [blocktry(:,2:W+6,:),zeros(H+6,1,4)]; end
            % update block if try hits nothing
            if max(max(block(4:H+3,4:W+3,ortry)+field)) < 2
                block = blocktry; or = ortry;
            end
            action = 1;
        end
        % move all the way down
        if move == 9 && paused == 0
            speedup = 1;
        end
        % move down one step
        if speedup == 1 || ~mod(counter,invspeed)
            if sum(block(4,:,or)) == 0
                blocktry = [block(2:end,:,:);zeros(1,W+6,4)];
                if max(max(blocktry(4:H+3,4:W+3,or)+field)) >= 2
                    field = field + block(4:H+3,4:W+3,or);
                    speedup = 0;
                    [block or] = createblock(H,W,level);
                    if max(max(block(4:H+3,4:W+3,or) + field)) >= 2
                        play = 0;
                    end
                else
                    block = blocktry;
                end
            else
                field = field + block(4:H+3,4:W+3,or);
                speedup = 0;
                [block or] = createblock(H,W,level);
            end
            counter = 0; action = 1;
        end
        move = 0;
        % plot
        if action == 1
            [i,j]= find(block(4:H+3,4:W+3,or) + field);
            plot(j,i,'s','MarkerSize',18,'MarkerEdgeColor','k','MarkerFaceColor','b')
            axis([0 W+1 0 H+1])
            set(gca,'XTick',[],'YTick',[])
        end 
        action = 0;
        
    end % end while
 
handles.barrier = uicontrol('parent',fig,'tag','barrier','style','text','position',[30 30 100 100],'backgroundcolor',[0 0 0]);
    if play == 0 % 'GAME OVER'
        for m=1:H
            [i,j]= find(block(4:H+3,4:W+3,or) + field);
            [k,l]= find(ones(m,W));
            hold on
            plot(j,i,'s','MarkerSize',18,'MarkerEdgeColor','k','MarkerFaceColor','b')
            plot(l,k,'s','MarkerSize',18,'MarkerEdgeColor','k','MarkerFaceColor','b')
            axis([0 W+1 0 H+1])
            set(gca,'XTick',[],'YTick',[])
            title(strcat('score: ',int2str(score)))
            drawnow
            pause(pauseremove)
            hold off
        end
        for m=H-1:-1:0
            [k,l]= find(ones(m,W));
            plot(l,k,'s','MarkerSize',18,'MarkerEdgeColor','k','MarkerFaceColor','b')
            axis([0 W+1 0 H+1])
            set(gca,'XTick',[],'YTick',[])
            title(strcat('score: ',int2str(score)))
            drawnow
            pause(pauseremove)
        end
        fprintf('Thanks for playing Tetris!\n')
        file = strcat('tetris',int2str(level),int2str(randomrows),int2str(invspeed),'.score');
        fid = fopen(file,'r');
        if fid == -1, high = -1; % file does not exist
        else, high = fscanf(fid,'%u'); end % get highscore from file
        if high >= score
            fprintf('Your score is: %u\n',score);
        else
            fprintf('Well done! You got a new high score: %u\n',score);
            fid = fopen(file, 'w');
           
        end
        fclose(fid);
    end
    close all
 
    % key handling
    function Key_Down(src,event)
        switch sprintf('%c',event.Key)
            case 'leftarrow',  move = -1;
            case 'rightarrow', move = 1;
            case 'downarrow',  move = 9;
            case 'z',          move = -2;
            case 'shift',      move = -2;
            case 'space',      move = 2;
            case 'x',          move = 2;
            case 'control',    move = 2;
            case 'escape',     play = -1;
            case 'p',          paused = ~paused;
            case 'pause',      paused = ~paused;
        end
    end
end
 
%block 생성 함수
function [block or] = createblock(H,W,level)
    % --------------------------------------------
    % TETRIS - CREATE BLOCK - by Jan de Gier, 2011
    % --------------------------------------------
    block = zeros(H+6,W+6,4);
    v = [0 0 0 0]; h = [0 0 0 0]; % to adjust location
    % create random block
    switch level
        case -3,b = -4;               % boring:   1?
        case -2,b = floor(4*rand)-4;  % noobish:  small
        case -1,b = floor(11*rand)-4; % easy:     small+regular
        case 0, b = floor(7*rand);    % normal:   regular
        case 1, b = floor(29*rand)-4; % hard:     all
        case 2, b = floor(25*rand);   % heroic:   regular+huge
        case 3, b = floor(18*rand)+7; % suicidal: huge
    end
    switch b
        %small blocks
        case -4,miniblock = 1;                                 % . 
        case -3,miniblock = [1 1];                             % i
        case -2,miniblock = [1 1;1 0];                         % ^ 
        case -1,miniblock = [1 1 1]; v(2)=1; v(4)=1;           % 1
        % regular blocks
        case 0, miniblock = [1 1 1 1]; v(2)=1; v(4)=1;         % I 
        case 1, miniblock = [1 1;1 1];                         % O 
        case 2, miniblock = [1 1;0 1;0 1]; v(3)=1; h(4)=-1;    % J 
        case 3, miniblock = [0 1;0 1;1 1]; v(3)=1; h(4)=-1;    % L 
        case 4, miniblock = [1 0;1 1;1 0]; v(1)=1; h(2)=-1;    % v 
        case 5, miniblock = [1 0;1 1;0 1];                     % s 
        case 6, miniblock = [0 1;1 1;1 0]; h(1)=1; h(3)=1;     % z 
        % huge blocks
        case 7, miniblock = [0 1 0;1 1 1;0 1 0];               % + 
        case 8, miniblock = [1 1;0 1;1 1]; v(3)=1; h(4)=-1;    % U 
        case 9, miniblock = [1 1 1;0 1 0;0 1 0];               % T 
        case 10,miniblock = [1 1 0;0 1 0;0 1 1];               % Z 
        case 11,miniblock = [0 1 1;0 1 0;1 1 0];               % S 
        case 12,miniblock = [1 1 0;0 1 1;0 0 1];               % W 
        case 13,miniblock = [0 1 1;1 1 0;0 1 0];               % F 
        case 14,miniblock = [1 1 0;0 1 1;0 1 0];               % 7
        case 15,miniblock = [1 1;1 1;1 0]; h(1)=1;v=[1 1 1 0]; % P 
        case 16,miniblock = [1 1;1 1;0 1]; h(1)=1;v=[1 1 1 0]; % q 
        case 17,miniblock = [1 1 1;1 0 0;1 0 0];               % V
        case 18,miniblock = [1 1 1 1;1 0 0 0]; v(2)=1; v(4)=1; % ? 
        case 19,miniblock = [1 1 1 1;0 0 0 1]; v(2)=1; v(4)=1; % ~ 
        case 20,miniblock = [1 1 1 1;0 1 0 0]; v(2)=1; v(4)=1; % Y
        case 21,miniblock = [1 1 1 1;0 0 1 0]; v(2)=1; v(4)=1; % K
        case 22,miniblock = [1 1 1 0;0 0 1 1]; v(2)=1; v(4)=1; % / 
        case 23,miniblock = [0 1 1 1;1 1 0 0]; v(2)=1; v(4)=1; % \ 
        case 24,miniblock = [1 1 1 1 1]; v(2)=2; v(4)=2;       % | 
    end
    for k=1:4
        miniblock = rot90(miniblock);
        [i,j] = size(miniblock);
        block(:,:,k) = [zeros(H-i+3-v(k),W+6);zeros(i,W/2-ceil(j/2)+3+h(k)),miniblock,zeros(i,W/2-floor(j/2)+3-h(k));zeros(3+v(k),W+6)];
    end
    % rotate block to random orientation
    or = floor(4*rand)+1;
    % correct for a low starting location
    while v(or) ~= 0
        v(or) = v(or)-1;
        block = [zeros(1,W+6,4);block(1:H+5,:,:)];
    end
end
 
%장님 아이템 누르면 장애물이 생성
function makebarrier(hobject,eventdata)
global fig
set(findobj(fig,'tag','barrier'),'visible','on');
set(findobj(fig,'tag','pushpush'),'visible','on');
end
 
%barrier을 10번 누르면 깨짐. 버튼 누를 때마다 색이 바뀌도록 설정
function escape_barrier(hobject,eventdata)
global fig;
global main;
global push_cnt;
if push_cnt < 10
push_cnt = push_cnt + 1;
push_color_b = 1 - push_cnt * 0.05;
push_color_g = 1 - push_cnt * 0.05;
barrier_color_g =  push_cnt * 0.1;
set(findobj(fig,'tag','pushpush'),'backgroundcolor',[0 push_color_g push_color_b]);
set(findobj(fig,'tag','barrier'),'backgroundcolor',[1 barrier_color_g 0.3]);
if push_cnt == 5 
    set (findobj(fig,'tag','barrier'),'string','깨질듯..');
    set (findobj(fig,'tag','pushpush'),'string','쫌만더');
end
    
elseif push_cnt == 10
set(findobj(fig,'tag','pushpush'),'visible','off');
set(findobj(fig,'tag','barrier'),'visible','off');
set(findobj(main,'tag','onemore'),'enable','off');
end
end