function main
clear all; close all; clc;

global G; global l;
get_settings();
start_game();
create_game();
 
tic; % start timer
while G.playing
    if G.moving==0, tic; drawnow; continue; end
    if G.moving==1, dt=toc; % Get time since last bounce
    else, dt=.1; G.moving=0;
    end
    if dt<.05, continue; end % prevents updates of less than 1/20 of a second
    tic; % reset timer
    
    % new position and velocity:
    
    G.user_x=G.user_x+G.vx*dt+.5*G.ax*dt*dt;
    G.user_y=G.user_y+G.vy*dt+.5*G.ay*dt*dt;
    G.vx=G.vx+G.ax*dt;
    G.vy=G.vy+G.ay*dt;

    update_game
    end
   
close(1)
return

function keyhandle(src,ed)
global G
if G.fuel ~=0
switch ed.Key
    case 'q'
        G.playing=0;
    case 'leftarrow'
        G.vx=G.vx-G.dv;
        G.fuel = G.fuel - 1;
    case 'rightarrow'
        G.vx=G.vx+G.dv;
        G.fuel = G.fuel - 1;
    case 'uparrow'
        G.vy=G.vy+G.dv;
        G.fuel = G.fuel - 1;
end
end 
return

function get_settings
global G;

G.firsttime = 1;
G.playing=1;
G.moving=1;
G.xmax=200;
G.ymax=200;

G.user_x=(G.xmax-5)*rand(1); % starting position
G.user_y=(G.ymax-5)*rand(1);
G.vx=0;  % starting x velocity
G.vy=0;
G.ax=0; %starting accelaration
G.ay=-1.6; %moon's gravitational accelaration is 1.6 m/s
G.fuel = 200;
G.dv=0.5;

return
 

function create_game
global G; global l; 

stars = (G.ymax-10).*rand(1,1000);
plot(stars, 'w.');

G.ship= image(imresize(imread('spaceshipup5.png'),0.2));

G.landx = linspace(0,G.xmax,1000);
G.landy = 3+0.9.*sin(1.72.*G.landx.*rand()).*cos(G.landx.*rand().*0.2)
area(G.landx,G.landy, 'FaceColor', [0.4 0.4 0.5]);

G.wx = (G.xmax-15)*rand()+5; %setting landing pad position
G.wy = min(G.landy)+0.5;
G.pad = image(imresize(imread('landingpad.png'),0.4));
set(G.pad,'Xdata',G.wx, 'Ydata',G.wy);
return

function start_game
% set up figure window
global G;

G.fig = figure(1);
set(G.fig, 'color', [0 0 0])
hold all;
axis equal;
axis([0 G.xmax 0 G.ymax]);
title('Moon Lander');
rectangle('Position',[0,0,G.xmax,G.ymax])
axis off;

if G.firsttime == 1
    G.firsttime = 0
    text(27, 147, 'Lunar Lander', 'color', [0.3 0.5 1], 'FontSize', 30)
    text(30, 150, 'Lunar Lander', 'color', [0.5 1 0.5], 'FontSize', 30)
    text(22, 100, 'Use the up/left/right directional keys to move', 'color', [1 1 1])
    text(-3, 90, 'Land on the pad at a speed of less than -6m/s to land safely','color', [1 1 1])
    text(7, 60, 'Press any key to continue','color', [1 1 1], 'FontSize', 20)
   
    G.ship= image(imresize(imread('spaceshipup5.png'),0.2))
    G.landx = linspace(0,G.xmax,1000);
    G.landy = 3+0.97.*sin(0.17.*G.landx).*cos(G.landx.*0.27)
    area(G.landx,G.landy, 'FaceColor', [0.4 0.4 0.5]);
    

    G.wy = min(G.landy)+0.5;
    G.pad = image(imresize(imread('landingpad.png'),0.4));
    set(G.pad,'Xdata',(G.xmax-50), 'Ydata',G.wy);
    set(G.ship, 'Xdata', 11, 'Ydata', 143);
    
    waitforbuttonpress
    cla
end
% set the function that gets called when a key is pressed
set(gcf,'WindowKeyPressFcn',@keyhandle);
G.stattext_h = text(G.xmax-130,G.ymax, ' ', 'verticalalign', 'top');
G.exit_text = text(0, G.ymax, ' ', 'verticalalign', 'top');
return

function update_game
global G; global l;
set(G.stattext_h, 'String', ...
    sprintf('Fuel=%.0f velocity=%.1f accelaration=%.1f', G.fuel, G.vy, G.ay), 'color', 'w'); %shows how much fuel is left and the speed of the craft
set(G.exit_text, 'String', sprintf('Q = quit'), 'color', 'w');

%ship wraps around if user goes all the way to the left/right side of the
%screen
if G.user_x > (G.xmax+2) 
    G.user_x = G.user_x - G.xmax;
elseif G.user_x < -2
    G.user_x = G.user_x + G.xmax;
end

%game end conditions
if (G.user_y>G.ymax && G.vy>5)
        G.space = text(15,G.ymax/2,'Oh no, you flew off into space!', 'color','r', 'Fontsize', 16, 'FontWeight', 'bold')
        end_game()
 elseif (G.user_y<=(G.wy+1) && (G.user_x<G.wx-3 || G.user_x>G.wx+18))
        G.crash = text(45,G.ymax/2,'Boy, are you inept!', 'color', 'w', 'Fontsize', 16, 'FontWeight', 'bold')
        end_game()
 elseif (G.user_y<=(G.wy+6) && G.user_x>=(G.wx-3) && G.user_x<=(G.wx+18) && G.vy>=-6)
        G.win = text(60,G.ymax/2,'safe landing!', 'color', 'w', 'Fontsize', 16, 'FontWeight', 'bold')
        end_game()
elseif (G.user_y<=(G.wy+6) && G.user_x>(G.wx-3) && G.user_x<(G.wx+18) && G.vy<-6)
        G.crash = text(45,G.ymax/2,'Boy, are you inept!', 'color', 'w', 'Fontsize', 16, 'FontWeight', 'bold')
        end_game()
end


    
%move ship to new position

set(G.ship,'XData',G.user_x);
set(G.ship,'YData',G.user_y);

% update display

drawnow
return

function end_game()
global G
pause(1.5)
G.playing = 0;
return
