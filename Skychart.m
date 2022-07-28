rawTable = TableLoad("E:\Documents\MATLAB\Worldbuilding\Matlab Star Catalogue.xlsx");
                                                   % Importing Matlab Star Catalogue excel file

x = 15.*(rawTable.RA - 12);                       % Converting Right Ascension to 360 units to create an equirectangular projection
y = ((-(-rawTable.Dec + 90)) + 180);
r = 0.0625*((2^(1/3)).^(-rawTable.AppMag + 9));    % Reverse exponential function setting visually digestible radii for each star marker
n = 100;                                           % Sets number of vertices of each star marker polygon

Names = split(rawTable.Names,{' ','-'});
Names(:,[2,4,5,6]) = [];

Xmult = [];                                        % Creating two empty reference arrays to continuously append in for loop
Ymult = [];

THETA=linspace(0,2*pi,n);                          % Creates array of n points evenly spread between 0 and 2pi
for i = 1 : length(x)                              % For loop that iterates through the entire length of the Star catalogue
    RHO=ones(1,n)*r(0+i);                          % Creates array of n points all multiplied by the radius array, which increments with for loop 
    [X,Y] = pol2cart(THETA,RHO);                   % Command converting polar coordinates theta and rho into two arrays of n cartesian coordinates x and y
    X=X+x(0+i,1);                                  
    Y=Y+y(0+i,1);                                  % Incrementing cartesian arrays by the proper coordinates to create a circular set of coordinates distributed around the circle center
    Xvert = X.';                                   
    Yvert = Y.';                                   % Transposing the two vertical cartesian coordinate arrays into vertical format so that fill() can read them

    Xmult = [Xmult Xvert];                         %
    Ymult = [Ymult Yvert];                         % Appending each iteration of the cartesian arrays to two arrays then containing each circle's set of x or y coordinates vertically
end


PolyArray=fill(Xmult,Ymult,'black','EdgeColor',[1 1 1]);   % Fill command that draws every circle at once, colored in black with a white edge to help distinguishing overlapping circles
xlim([-180 180])
pbaspect([2 1 1]);                                 % Locking aspect ratio to square so that the circles don't render as ovals

rsc_rows = find(Names(:,1) == "RSC");              % outputs a list of all line numbers with a star containing the indicator "RSC" for 'cluster star'
prefixes = unique(Names(rsc_rows,2));              % creates a group of numbers that contains each unique cluster specific code, and ignores codes not specific to a cluster star
dubNames = str2double(Names(:,2));                 % converts each star prefix code into a numerical double

Centroids = [];                                    % pre-allocates(ish) the arrays for the calculated xy centroid coordinate of each cluster, and ...
neb_radii = [];                                    % pre-allocates(ish) the distance to the farthest cluster star from the centroid
Valid_prefix = [];
for i = 1 : length(prefixes)                       % For loop that iterates for each cluster prefix
    prefixloop = str2double(prefixes(0 + i));      % converts each string value prefix into a numerical double temporarily
    Clist = find(dubNames == prefixloop);          % Creates a list containing the line number of every star with a prefix matching the temporary numerical double
    C_mid = [mean(x(Clist)) mean(y(Clist))];       % Generates the Centroid xy coordinate of each cluster from the mean xy coordinate of each star identified
    cellprefix = (prefixes(0 + i));
    
    distset = [];                                  % pre-allocates(ish) the array of each distance from every cluster star to their respective centroid
    for j = 1 : length(Clist)                      % For loop that iterates within the first for loop, over every star within the current list of cluster stars
    dist = norm(C_mid - [x(Clist(j,1)) y(Clist(j,1))]);    % Finds the distance via normal vector of the star from the centroid
    distset = [distset; dist];                     % Adds the distance from the centroid to a cumulative list, showing every distance from the current cluster centroid
    end

        if max(distset) < 4                        % If statement checking if the maximum star distance from the current cluster is below a certain threshold, assuming that
                                                   % above the threshold the stars are sufficiently spread out to be visually un-cluttered
            neb_radii = [neb_radii; max(distset)]; % Adds the maximal cluster distance to a list showing effective visual circular radii of each cluster
            %delete(PolyArray(Clist));             % Deletes every star marker for each cluster identified to be below a certain visual size
            Centroids = [Centroids; C_mid];        % Adds the current calculated cluster centroid to a cumulative list if it is eligable
            Valid_prefix = [Valid_prefix; cellprefix];     % Creates a cumulative list of every string prefix 
        else continue                              % Ignores every cluster above the size threshold
        end 
end 

viscircles(Centroids,neb_radii.*1.1,'Color','black');     % Draws a hollow black circle around each valid xy centroid coordinate, with a radius 1.1x as large as the calculated cluster size
text(Centroids(:,1),Centroids(:,2),Valid_prefix);


