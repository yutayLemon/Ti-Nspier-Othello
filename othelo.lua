screen = platform.window;
h = screen:height();
w = screen:width();
dh = h/100;
dw = w/100;
InputText = "";
mousePos = {};
mousePos.x = 0;
mousePos.y = 0;
n=8;
cellSize = dh*8;
board = {};
xPos = 1;
yPos = 1;
boardX = dw*8;
boardY = dh*9;
side = 1;
BlackSum  = 0;
WhiteSum = 0;
endGame = false;
FlipMatrix = {{},{},{},{},{},{},{},{}};
currentMove = {1,1};
TextMove = {};
GameRules = {
startingSide = 2,
computorSide = 2,
pvpOn = true,
NextMovesOn = true
};

function on.charIn(char)
    InputText = InputText..char;
    --print(InputText);
    if(tonumber(char) and (tonumber(char)>=1 and tonumber(char) <= 8))then
    if(TextMove[1] == nil )then
        TextMove[1] = tonumber(char);
    elseif(TextMove[2] == nil)then
        TextMove[2] = tonumber(char);
    end
    end
    if(char=="r")then
        InitBoard(GameRules.startingSide);
        if(not GameRules.pvpOn)then
                 turnComp();
                end
    end
    if(char=="t")then
        GameRules.pvpOn = not GameRules.pvpOn;
        if(not GameRules.pvpOn)then
         turnComp();
        end
                    
    end
    if(char=="p")then
            GameRules.NextMovesOn =  not GameRules.NextMovesOn;           
        end
         screen:invalidate();
end

function on.backspaceKey()
    InputText = string.sub(InputText,1,string.len(InputText) -1);
    if(TextMove[2]==nil)then
        TextMove[1]=nil;
    else
    TextMove[2]=nil;
    end
    
         screen:invalidate();
end

function on.enterKey()
    if(not (TextMove[2] == nil))then
    currentMove = TextMove;
    print(currentMove[1].."--"..currentMove[2]);
    if(GameRules.pvpOn)then
                turnPlayers();
                else
                turn();
                end
      TextMove = {};
      end
     screen:invalidate();
end

function Computor(side)
    local maxVal = 0;
    local maxMove = {0,0};
    local options = possibalMoves(side)
    for i=1,#options do
            local newVal = cellRank(options[i])+FlipMatrix[options[i][1]][options[i][2]]+PattenRank(options[i],side);
            if newVal > maxVal then
                maxVal = newVal;
                maxMove = options[i]
            end
    end
    return maxMove;
end

function cellRank(cell)
    local rank = {
    {100,15,55,55,55,55,15,100},
    {15,10,50,30,30,50,10,15},
    {55,50,50,40,40,50,50,55},
    {55,30,40,90,90,40,30,55},
    {55,30,40,90,90,40,30,55},
    {55,50,50,40,40,50,50,55},
    {15,10,50,30,30,50,10,15},
    {100,15,55,55,55,55,15,100}
    }
    return rank[cell[1]][cell[2]];
end

function PattenRank(cell,side)
    return 0;
end








function InitBoard(start)
    side = start;
    BlackSum  = 2;
    WhiteSum = 2;
    endGame=false;
    for i=1,n do
        board[i] = {};
        for j=1,n do
            board[i][j] = 0;
        end
    end
    board[4][4] = 2;
    board[5][5] = 2;
    board[5][4] = 1;
    board[4][5] = 1;
end

InitBoard(1);
print(#board[1]);

function renderText(gc,text,width,x,y)
    local tempstr = "";
    for i=1,#text do
    tempstr = tempstr..text:sub(i,i);
        if(i%width == 0)then
              gc:drawString(tempstr,x,y);
              y=y+10;
              tempstr = "";
        end
    end
    gc:drawString(tempstr,x,y);
    return y+10;
end

function drawGrid(x,y,gc)
    gc:setFont("sansserif","r",9);
    
    
    local textX = x+cellSize*8.5;
    local yEnd = renderText(gc,"-p to turn placable moves on/off",26,textX,
    renderText(gc,"-r to restart",26,textX,
    renderText(gc,"-t to switch computor on/off",26,textX,
    renderText(gc,"-click to make move or input coordinates (x-y) and enter",26,textX,y)
    )
    )
    );
    gc:drawString("white:"..WhiteSum,x+cellSize*4,cellSize*10+y);
    gc:drawString("black:"..BlackSum,x,cellSize*10+y);
    if(GameRules.pvpOn)then
        gc:drawString("compON:false",x+cellSize*11,yEnd+cellSize);
    else
        gc:drawString("compON:true",x+cellSize*11,yEnd+cellSize);
    end
    if(not endGame)then
    if(side == 1)then
        gc:drawString("payer1(white)'s turn",x+cellSize*9,yEnd+cellSize*2);
    else
        gc:drawString("player2(black)'s turn",x+cellSize*9,yEnd+cellSize*2);
    end
    end
    
    if(not (TextMove[2] == nil))then
        gc:setColorRGB(255,0,0);
        gc:setPen("thin","dashed");
        gc:drawArc(x+cellSize*(TextMove[1]-1)+cellSize*(1/6),y+cellSize*(TextMove[2]-1)+cellSize*(1/6),cellSize*(2/3),cellSize*(2/3),0,360);
        gc:setColorRGB(0,0,0);
        gc:setPen("thin","smooth");
    end
    local tMove = "next move:";
       if(TextMove[1]==nil or (TextMove[1] < 1 or TextMove[1] > 8))then
           tMove = tMove .. " ";
       else
        tMove = tMove .. TextMove[1];
       end
       tMove=tMove.."-";
            if(TextMove[2]==nil  or (TextMove[2] < 1 or TextMove[2] > 8))then
                tMove = tMove .. " ";
            else
             tMove = tMove .. TextMove[2];
            end
       gc:drawString(tMove,x,cellSize*8.5+y);
    for i=0,n do
       if((i+1) <= 8)then
       gc:drawString((i+1).."",x+cellSize*i,y-cellSize)
       end
       gc:drawLine(x+cellSize*i,y,x+cellSize*i,y+cellSize*8); 
    end
    for i=0,n do
        if((i+1) <= 8)then
        gc:drawString((i+1).."",x-cellSize,y+cellSize*i);
        end
       gc:drawLine(x,y+cellSize*i,x+cellSize*8,y+cellSize*i); 
    end
    for i=1,n do
        for j=1,n do
            local cellState = board[i][j];
            if(cellState == 1)then
                 gc:drawArc(x+cellSize*(i-1),y+cellSize*(j-1),(cellSize),(cellSize),0,360); 
            elseif(cellState == 2)then
                 gc:fillArc(x+cellSize*(i-1),y+cellSize*(j-1),(cellSize),(cellSize),0,360);
            elseif  cellState == 0 then
            else
                 print("error");
            end
        end
    end
end

function flipChain(present,color,direct,Cmode)
    --print(present[1].."-"..present[2]);
    local OutOfBounds;
    if ((present[1] < 1 or present[1] > 8)or(present[2] < 1 or present[2] > 8))then
         OutOfBounds = true;
    else
    
         OutOfBounds =false;
    end
    --outof bounds or
    if(OutOfBounds)then
        return 0;
    end
    if(board[present[1]][present[2]] == 0)then
        return 0;
    elseif(board[present[1]][present[2]] == color)then
        return 1;
    else
        local nextCell = {present[1]+direct[1],present[2]+direct[2]};
        local FlipCount = flipChain(nextCell,color,direct,Cmode);
        if(FlipCount > 0)then
            if(not Cmode)then
                board[present[1]][present[2]] = color;
            end
            --print("flipss"..(FlipCount+1))
            return FlipCount+1;
        else
            return 0;--iliagl move
        end
    end
end

function FlipTo(move,color,Cmode)
    local directions = {{0,1},{1,0},{0,-1},{-1,0},{1,1},{-1,-1},{-1,1},{1,-1}};
    local FlipCount = 0;
    for i=1,8 do
        local temp = flipChain({move[1]+directions[i][1],move[2]+directions[i][2]},color,directions[i],Cmode);
        if temp > 0 then
            FlipCount=FlipCount+temp-1;
        end
    end
    return FlipCount+1;
end


function MakeMove(x,y,color)
    local flips = 0;
    print(x.."="..y);
    if(board[y][x] == 0)then
     flips = FlipTo({y,x},side,false);
    end
    
    if(flips <= 1)then
        print("illigal move");
    else
       board[y][x] = color;
       side = (side%2)+1; 
    end
    
     screen:invalidate();
     if(#possibalMoves(side)==0)then
                side = (side%2)+1;
     end
     if(#possibalMoves(1) == 0 and #possibalMoves(2)==0)then
                endGame=true;
     end
                  
end

function possibalMoves(color)
WhiteSum=0;
BlackSum=0;
    local Moves = {};
    for i=1,n do
        for j=1,n do
            local flips = 0;
            local surrounded = false;
            if(board[i][j] == 0)then
            local res = FlipTo({i,j},color,true);
           -- print(res);
               if(res>1)then
                             Moves[#Moves+1] = {i,j};
                         end
                FlipMatrix[i][j]=res;
            elseif(board[i][j]==1)then
                WhiteSum = WhiteSum+1;
            elseif(board[i][j]==2)then
                BlackSum=BlackSum+1;
            else
            
            end
        end
    end
    return Moves;
end

function renderPossibalMoves(gc,Moves)
    for i=1,#Moves do
        gc:drawArc((boardX)+cellSize*(Moves[i][1]-1)+cellSize/3,(boardY)+cellSize*(Moves[i][2]-1)+cellSize/3,(cellSize/3),(cellSize/3),0,360);
    end
end

function Close(gc)
    gc:setFont("sansserif","r",12);
     if(WhiteSum > BlackSum)then
     gc:drawString("white wins",cellSize*10,cellSize*10);
     elseif(WhiteSum < BlackSum)then
        gc:drawString("black wins",cellSize*10,cellSize*10);
     else
     gc:drawString("draw",cellSize*10,cellSize*10);
     end
     gc:setFont("sansserif","r",9);
end

function turnComp()
     while(side ==GameRules.computorSide and not endGame)do
   local temp = Computor(side);
   MakeMove(temp[2],temp[1],side);
  end
end

function turn()
    if(not endGame)then
    if(side == (GameRules.computorSide%2)+1)then
    MakeMove(currentMove[2],currentMove[1],side);
    turnComp();
   end
   end
end

function turnPlayers()
    if(not endGame)then
    MakeMove(currentMove[2],currentMove[1],side);
   end
end

function on.mouseDown(x,y)
    mousePos.x = x;
    mousePos.y = y;
    
    
    temp = math.floor((x-boardX)/cellSize);
    if(temp >=0 and temp <= 7)then
        xPos = temp;
    end
    temp = math.floor((y-boardY)/cellSize);
    if(temp >=0 and temp <= 7)then
        yPos = temp;
    end
    currentMove = {xPos+1,yPos+1};
   -- print(temp);
   
     if(GameRules.pvpOn)then
               turnPlayers();
               else
               turn();
               end
     
end


function on.paint(gc)
    drawGrid(boardX,boardY,gc);
   
    if(endGame)then
        Close(gc);
    else
    if(GameRules.NextMovesOn)then
        renderPossibalMoves(gc,possibalMoves(side));
        end
    end
end