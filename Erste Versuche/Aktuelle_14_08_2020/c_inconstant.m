 clf;
 clear all;
 close all;
 %Ausbreitungskoeffizient (Diffusionskoeffizient)
 %beschreibt nur die Ausbreitung im Raum
 c_0 = 0.1;
 c=c_0;
 
 
 %Infektionsrate
 %Wkeit, dass eine Person im Raum infiziert wird
 infektionsrate=0.3258;
 
 %Wechselrate
 w=(1/14);
 
 %Zeitvariablen
 tage = 1;
 delta_t = 0.01;
 Zeitschritte = floor(tage/delta_t);
 
 %-------
 %slowdown fuer Hr c)!
 
 %-------
 
 %Bev�lkerungsmatrix --------- 
 B = getBevDichteMatrix();
 sizeX= size(B)(2); %entspricht xend also x in km
 sizeY= size(B)(1); %entspricht yend also y in km
 N=sizeX*12; %sizeX ist x in km -> * 10 = 100m Raster
 h = sizeX/(N);
 M=sizeY/h;
 colormap ("hot");
 
 %B=zeros(4,5).+232;
 
 





 x = 0:1:size(B)(2)-1;  y = 0:1:size(B)(1)-1;
 xi = linspace (min (x), max (x), N); %Anzahl der Unterteilungen
 yi = linspace (min (y), max (y), M)'; %Anzahl der Unterteilungen
 BInt = interp2 (x,y,B,xi,yi, "cubic");
 figure(1001)
 surface (xi,yi,BInt);
 [x,y] = meshgrid (x,y);
 hold on;
 plot3 (x,y,B,"bo");
 title ("Bevoelkerungsdichte Landau");
 ylabel("y")
 xlabel("x")
 
 

if(size(x)(2)>size(y)(2))
 axis_value = size(x)(2)-1;
else
 axis_value = size(y)(2)-1;
endif
 axis([0 axis_value 0 axis_value])
 colorbar
 hold off;
 %--------------------------------------------- 
 %Systemmatrix --------- 

 A_h = 1*calcSysMatrixCNichtKonstant(N,M,c,h);
 %spy(A_h)
 B = 1*reshape(BInt',N*M,1);
 
 %infizierteStartMatrix------------------- 
 u_i_alt = 10*reshape(getInfizierteStartMatrix(N,M,h)',N*M,1); 
 u_s_alt = B.-u_i_alt; 
 %--------------------------------------------- 
 figure(1000)
 surface(xi,yi,reshape(u_i_alt,N,M)', "EdgeColor", "none");
 title (["Anfangszustand"]);
 
 for t=1:Zeitschritte
 %LoesungsSpeicherMatrix(:,1) = u_i_alt;
 %LoesungsSpeicherMatrixS(:,1) = u_s_alt;
 infektionsrate_slow=slowdown3(t*delta_t)*infektionsrate;

 F_S=@(ui,us,t) -1*(infektionsrate_slow./B).*ui.*us; 
 %slowdown in c) berücksichtigen!
 
 F_I=@(ui,us,t) (infektionsrate_slow./B).*ui.*us-w*ui;
 

   
%reaktion = F(u_i_alt, u_s_alt,t*delta_t);
   
u_i = u_i_alt + delta_t* ( A_h*u_i_alt + (F_I(u_i_alt, u_s_alt,t*delta_t)));

u_s =  u_s_alt + delta_t*(A_h*u_s_alt+F_S(u_i_alt, u_s_alt,t*delta_t));

% till here ok - ab einem bestimmten Zeitschritt gehen die Werte gegen unendlich 
% und werden undefiniert - Bevölkerungsmatrix wird nicht korrekt berücksichtigt
u_i_alt = u_i;
u_s_alt = u_s;
LoesungsSpeicherMatrix(:,t) = u_i;
LoesungsSpeicherMatrixS(:,t) = u_s;
endfor

fig_index=floor([1:tage]./delta_t)

j=0;
 for i=fig_index
  sol_matrix=reshape(LoesungsSpeicherMatrix(:,i),N,M); % Matrix mit N(Zeilen)x M(Spalten)
  sol_matrix=sol_matrix';
  total_Infizierte=sum(sum(sol_matrix))*h^2
  total_Infizierte_Matrix(:,i*delta_t)=total_Infizierte;
  disp(['Figure ',num2str(i/fig_index(1))]);
  j=j+1;
  figure(j);
  surface(xi,yi,sol_matrix*h^2, "EdgeColor", "none")
 % colormap: autumn,  hsv jet ocean
  colormap ("jet")
  colorbar 
  %axis([0 sizeX 0 sizeY -0.001 max(B)])
  title (["Loesung in t=", num2str(delta_t*i)]);
  ylabel("y")
  xlabel("x")
  %Optional: Speicherung der Bilder
  test=["a-Fig_", num2str(j),".jpg"]
  saveas(j, test)
endfor

 %HINWEIS: DIE MUESSEN IN JEDEM SCHRITT BERECHNET WERDEN!
%----------------
 %Diffusionskoeffizient in Abhaengigkeit von der Bevoelkerungsdichte
 %Normierte Bevoelkerungsdichte
 %B_norm=1/sum(sum(BInt)).*BInt;
 %Lineare Abhaengigkeit
 a=1/2;
 c_lin=c_0+a.*BInt;
 %Nichtlineare Abhaengigkeit
 k_nlin=1/2;
 c_nlin=atan(k_nlin.*BInt.-k_nlin/2)+atan(k_nlin/2)+c_0;
%-----------------
 
%solmatrix fuer c_lin/c_nlin
sol_matrix1=sol_matrix*h^2;
c_lin1=zeros(rows(c_lin)+2,columns(c_lin)+2);
c_nlin1=zeros(rows(c_lin)+2,columns(c_lin)+2);

c_lin1(2:rows(c_lin1)-1,2:columns(c_lin1)-1)=c_lin;

%HIER WIRD ES MM nach in WIKIVERSITY SELTSAM oder w�hlen wir c in den R�ndern ==0?
%links und rechts
%c_lin1(:,1)=
%c_lin1(:,end)=

%oben und unten
%c_lin1(1,2:(end-1))=
%c_lin1(end,2:(end-1))=
%c_nlin1(2:rows(c_nlin1)-1,2:columns(c_nlin1)-1)=c_nlin;

%Neue Systemmatrix-----------
I_0=diag(c_lin1(1,:));
I_m1=diag(c_lin1(end,:));
%B_j=
%I_lj


%---------------