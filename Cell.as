package {
	import flash.display.*;
	import flash.events.*;
	public class Cell extends MovieClip 
	{
		public var count:Number;
		private var monsters:Array;
		private var hit:Boolean;
		private var game:Game;
		public var xIndex;
		public var yIndex;
		private var locked = false;

		public function Cell(game:Game, xIndex:int=0, yIndex:int=0, ct:Number=0)
		{
			LockedClip.visible = false;
			LockedClip.addEventListener(MouseEvent.CLICK, buttonClick);
			this.game = game;
			monsters = new Array();
			this.xIndex = xIndex;
			this.yIndex = yIndex;
			CellButton.addEventListener(MouseEvent.CLICK,buttonClick);
			x = xIndex*25;
			y = yIndex*25 + game.TOP_OFFSET;
			count = ct;
			NeighborText.background = false;
			updateCount(ct);
			hit = false;
			addChild(LockedClip);
		}

		public function isHit()
		{
			return hit;
		}

		public function hasMonsters()
		{
			return monsters.length > 0;
		}

		public function updateCount(t:Number)
		{
			count += t;
			var displayNumber = count;
			if(monsters.length > 0)
			{
				NeighborText.textColor = 0xee00fe;
				var sum = 0;
				for(var mindex in monsters)
				{
					sum+=monsters[mindex].type;
				}
				displayNumber = sum;
			}
			NeighborText.text = ""+displayNumber;
			if(displayNumber > 99)
				NeighborText.text = "D8";
			if(displayNumber > 149)
				NeighborText.text = "DX";
			if(displayNumber < 1)
				NeighborText.text = "";
			if(monsters.length > 0)
				NeighborText.text = "!!";
		}

		public function addMonster(m:Monster)
		{
			monsters.push(m);
			NeighborText.textColor = 0xee0000;
		}

		public function restart()
		{
			hit = false;
			setLock(false);
			CellButton.visible = true;
			count = 0;
			NeighborText.textColor = 0xffffff;
			while(monsters.length >0)
			{
				monsters.pop();
			}
			updateCount(0);
		}

		public function removeMonster(m:Monster)
		{
			for(var monsterIndex in monsters)
			{
				if(monsters[monsterIndex].type == m.type)
				{
					monsters.splice(monsterIndex, 1);
					break;
				}
			}
			if(!hasMonsters())
				NeighborText.textColor = 0xdede22;
		}

		private function setLock(lock:Boolean)
		{
			locked = lock;
			LockedClip.visible = locked;
		}

		public function buttonClick(e:MouseEvent)
		{
			trace("click!");
			trace(game.shiftPressed);
			if(game.shiftPressed)
			{
				setLock(!locked);
			}
			else if(!locked)
			{
				reveal();
				game.moveMonsters();
			}
		}

		public function reveal()
		{
			hit = true;
			CellButton.visible = false;
			if(count < 1)
			{
				game.propagate(xIndex,yIndex);
			}
			else if (monsters.length >0){
				game.fight(monsters);
			}
		}

	}
}
