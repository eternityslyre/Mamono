package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.ui.*;
	public class Game extends MovieClip
	{
		private var board:Array;
		public var BOARD_WIDTH = 30;
		public var BOARD_HEIGHT = 20;
		public var MONSTER_COUNT = 500;
		public var MAX_LEVEL = 30;
		public var TOP_OFFSET =30;

		public var shiftPressed = false;

		private var monsters:Array;
		private var shakeCounter:int;

		private var playerHP = 100;
		private var playerLevel = 1;
		private var playerExp = 0;
		private var HPText:TextField;
		private var LevelText:TextField;
		private var EXPText:TextField;
		private var BattleLog:TextField;

		public function Game(stage:Stage)
		{
			shakeCounter = 0;
			GameOverScreen.visible = false;
			GameOverScreen.StartOverButton.addEventListener(MouseEvent.CLICK, restartGame);
			GameOverScreen.alpha = 0.75;
			GameOverScreen.width = 25*BOARD_WIDTH;
			GameOverScreen.height= 25*BOARD_HEIGHT+TOP_OFFSET;
			GameOverScreen.x = 0;
			GameOverScreen.y = 0;
			HPText = new TextField();
			HPText.x = 0;
			HPText.y = 0;
			HPText.width = 70;
			HPText.height= 30;
			HPText.text = playerHP;

			LevelText = new TextField();
			LevelText.x = 100;
			LevelText.y = 0;
			LevelText.width = 70;
			LevelText.height= 30;
			LevelText.text = "Level: "+playerLevel;

			EXPText = new TextField();
			EXPText.x = 200;
			EXPText.y = 0;
			EXPText.width = 70;
			EXPText.height= 30;
			EXPText.text = "EXP: "+playerExp;

			BattleLog = new TextField();
			BattleLog.x = BOARD_WIDTH*25 +10;
			BattleLog.y = 0;
			BattleLog.width = 200;
			BattleLog.height= 400;
			BattleLog.text = "";
			BattleLog.wordWrap = true;

			board = new Array();
			monsters = new Array();
			for(var i = 0; i < BOARD_WIDTH; i++)
			{
				board[i] = new Array();
				for(var j = 0; j < BOARD_HEIGHT; j++)
				{
					var newCell = new Cell(this, i, j);
					board[i][j] = newCell;
					addChild(newCell);
				}
			}

			restartGame();	
			addChild(HPText);
			addChild(LevelText);
			addChild(EXPText);
			addChild(BattleLog);
			addChild(GameOverScreen);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(KeyboardEvent.KEY_UP,handleKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,handleKeyDown);
		}

		public function enterFrame(e:Event)
		{
			if(shakeCounter > 0)
			{
				shakeCounter --;
				x=Math.random()*10-5;
				y=Math.random()*10-5;
			}
			if(shakeCounter == 0)
			{
				x = 0;
				y = 0;
			}
		}

		public function handleKeyDown(e:KeyboardEvent)
		{
			if(e.keyCode == Keyboard.SHIFT)
			{
				trace("shiftdown");
				shiftPressed = true;
			}
		}

		public function handleKeyUp(e:KeyboardEvent)
		{
			if(e.keyCode == Keyboard.SHIFT)
			{
				trace("shiftup");
				shiftPressed = false;
			}
		}

		public function moveMonsters()
		{
			for(var m = 0; m < monsters.length; m++)
			{
				monsters[m].roam();
			}
		}

		private function logResults(s:String)
		{
			trace(s);
			BattleLog.appendText(s+"\n");
			BattleLog.scrollV = BattleLog.maxScrollV;
		}

		private function compareMonsters(a,b):int
		{
			return a.getHP() - b.getHP();
		}

		public function fight(mons:Array)
		{
			mons.sort(compareMonsters);
			logResults("Fight!! Number of mons: "+(mons.length));
			var playerDamage = playerLevel*5;
			var monsterCount = 0;
			while(playerDamage > 0 && mons.length > 0)
			{
				var nextMonster = mons.pop();
				var damage = Math.min(nextMonster.getHP(), playerDamage);
				logResults("Player strikes Monster "+monsterCount+" for "+damage+" damage!!");
				logResults("Monster "+monsterCount+" had "+nextMonster.getHP()+" HP!!");
				trace((mons.length +1  > 1) +", "+ (nextMonster.getHP() > 1) +", "+ (damage == nextMonster.getHP()));
				if(mons.length +1 > 1 && nextMonster.getHP() > 1 && damage == nextMonster.getHP()){
					logResults("There is more than one enemy! An enemy deflects the killing blow!");
					damage--;
				}
				nextMonster.takeDamage(damage);
				logResults("Monster "+monsterCount+" now has "+nextMonster.getHP()+" HP!!");
				playerDamage -= damage;
				if(nextMonster.died())
				{
					logResults("Monster "+monsterCount+" defeated!");
					addExp(nextMonster.type);
					logResults(mons.length + " mons remain.");
				}
				else mons.unshift(nextMonster);
				monsterCount++;
			}
			for(var i = 0; i < mons.length; i++)
			{
				logResults("Monster "+i+" strikes for "+mons[i].type+" damage!!");
				damagePlayer(mons[i].type);
			}

			for(var m = 0; m < mons.length; m++)
			{
				mons[m].roam();
			}
		}

		public function addExp(exp:int)
		{
			playerExp += exp;
			logResults("Gained "+exp+" experience.\n Total experience: "+playerExp+".\n To next level: "+(playerLevel*10));
			if(playerExp > playerLevel*10)
			{
				logResults("LEVEL UP!!");
				playerExp = playerExp - playerLevel*10;
				playerLevel++;
			}
			logResults("Next level in "+(playerLevel*10-playerExp)+" experience.");
			EXPText.text = "EXP: "+playerExp;
			LevelText.text = "Level: "+playerLevel;
		}

		public function damagePlayer(damage:int)
		{
			//damage = Math.min(0,damage-playerLevel*2);
			logResults("Taking "+damage+" damage!");
			playerHP-=damage;
			shakeCounter = 5 + int(damage/10);
			HPText.text = playerHP;
			if(playerHP<1)
			{
				GameOverScreen.visible = true;
			}
		}

		public function restartGame(e:Event=null)
		{
			playerHP = 100;
			playerLevel = 1;
			LevelText.text = playerLevel;
			HPText.text = playerHP;
			BattleLog.text = "Game Start!";
			for(var i = 0; i < BOARD_WIDTH; i++)
			{
				for(var j = 0; j < BOARD_HEIGHT; j++)
				{
					board[i][j].restart();
				}
			}
			var newX = int(Math.random()*BOARD_WIDTH);
			var newY = int(Math.random()*BOARD_HEIGHT);
			for (var k = 0; k < MONSTER_COUNT; k++)
			{
				var newType = 1+ int(Math.random()*MAX_LEVEL);
				if(monsters[k]===undefined)
					monsters[k] = new Monster(board, 0, 0, 0);
				if(Math.random()*newType/MAX_LEVEL > 0.5){
					newX = int(Math.random()*BOARD_WIDTH);
					newY = int(Math.random()*BOARD_HEIGHT);
				}
				monsters[k].reinit(newX, newY, newType);
			}
				GameOverScreen.visible = false;
		}

		public function propagate(cellX:int, cellY:int)
		{
			for(var i = -1; i < 2; i++)
			{
				for(var j= -1; j < 2; j++)
				{
					if(board[cellX+i] !== undefined && board[cellX+i][cellY+j] !== undefined
						&& !board[cellX+i][cellY+j].isHit())
						board[cellX+i][cellY+j].reveal();
				}
			}
		}
	}
}
