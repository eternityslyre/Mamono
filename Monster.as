package {
	public class Monster
	{
		public var type:int;
		private var cellX:int;
		private var cellY:int;
		private var board:Array;
		private var validMoves:Array;
		private var dead:Boolean;
		private var hp:int;

		public function Monster(gameBoard:Array, xIndex:int, yIndex:int, type:int)
		{
			board = gameBoard;
			cellX = xIndex;
			cellY = yIndex;
			this.type = type;
			hp = type;
			board[cellX][cellY].addMonster(this);
			updateBoard(type);
			validMoves = new Array();
			dead = false;
		}

		public function reinit(xIndex, yIndex, type)
		{
			this.type = type;
			hp = type;
			board[cellX][cellY].removeMonster(this);
			cellX = xIndex;
			cellY = yIndex;
			board[cellX][cellY].addMonster(this);
			updateBoard(type);
			dead = false;
		}

		private function updateBoard(val:int)
		{
			for(var i = -1; i < 2; i++)
			{
				for(var j= -1; j < 2; j++)
				{
					if(i == 0 && j ==0) continue;
					if(board[cellX+i] !== undefined && board[cellX+i][cellY+j] !== undefined)
						board[cellX+i][cellY+j].updateCount(val);
				}
			}
		}

		public function takeDamage(damage:int)
		{
			hp -= damage;
			if(hp<=0)
				die();
		}

		public function getHP()
		{
			return hp;
		}

		private function getNeighbor(x:int, y:int)
		{
			return board[x][y];
		}

		public function die()
		{
			dead = true;
			updateBoard(-type);
			board[cellX][cellY].removeMonster(this);
		}

		public function died()
		{
			return dead;
		}

		public function roam()
		{
			if(dead) return;
			if(Math.random()>1.0/type)
				return;
			while(validMoves.pop()!=null)
				validMoves.pop();
			for(var i = -1; i < 2; i++)
			{
				for(var j= -1; j < 2; j++)
				{
					var newCellX = cellX+i;
					var newCellY = cellY+j;
					if(board[newCellX]!==undefined && board[newCellX][newCellY] !== undefined
						&& !board[newCellX][newCellY].isHit())
					{
						validMoves.push(board[newCellX][newCellY]);
					}
				}
			}
			if(validMoves.length <1) return;
			var destination = validMoves[int(Math.random()*validMoves.length)];
			updateBoard(-type);
			board[cellX][cellY].removeMonster(this);
			destination.addMonster(this);
			cellX = destination.xIndex;
			cellY = destination.yIndex;
			updateBoard(type);
		}
	}
}
