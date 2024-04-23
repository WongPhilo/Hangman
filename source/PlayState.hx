package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.iterators.StringIterator;
import openfl.Assets;

class PlayState extends FlxState
{
	// Public groups
	public var alphabet:Array<String> = [
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
	];

	// Private groups
	private var _tiles:Array<Tile>;
	private var _selected:Array<String>;
	private var _dictionary:Array<String>;

	// Buttons
	private var reset:FlxButton;
	private var advance:FlxButton;
	private var hide:FlxButton;

	// Text
	private var guessed:FlxText;
	private var levtext:FlxText;
	private var overtext:FlxText;

	// Sprites
	private var hangman:FlxSprite;

	// Variables
	private var gameover:Bool;
	private var correct:Bool;
	private var word:String;
	private var turns:Int;
	private var lev:Int;

	/**
	 * Creates and initializes a new game state.
	 */
	override public function create():Void
	{
		super.create();
		_dictionary = new Array<String>();
		fillDictionary();
		correct = false;
		gameover = false;
		lev = 1;
		turns = 9;
		_tiles = new Array<Tile>();
		_selected = new Array<String>();
		var tileX = 10;
		var tileY = FlxG.height - 50;
		for (v in alphabet)
		{
			var _tile:Tile;
			_tile = new Tile(tileX, tileY, v, null);
			_tile.onDown.callback = testLetter.bind(v, _tile);
			_tile.label.color = FlxColor.WHITE;
			_tiles.push(_tile);
			add(_tile);
			tileX += 20;
			if (tileX > FlxG.width - 70)
			{
				tileX = 10;
				tileY = FlxG.height - 25;
			}
		}

		word = genWord();
		guessed = new FlxText(10, 10, "********", 20);
		levtext = new FlxText(10, 35, "Level: " + Std.string(lev), 20);
		hangman = new FlxSprite(170, 0);
		hangman.loadGraphic("assets/images/hangman" + Std.string(turns) + ".png");
		add(guessed);
		add(levtext);
		add(hangman);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	/**
	 * Checks if the given letter is found within the word. 
	 * @param str 	The letter provided to be tested.
	 * @param t 	The tile from which the letter originated.
	 */
	function testLetter(str:String, t:Tile):Void
	{
		if (gameover || correct || _selected.contains(str))
		{
			return;
		}

		t.label.color = FlxColor.RED;
		var si:StringIterator;
		var sb:StringBuf;
		var hit:Bool;
		hit = false;
		sb = new StringBuf();
		si = new StringIterator(word);
		_selected.push(str);
		while (si.hasNext())
		{
			var letter:Int;
			letter = si.next();
			if (String.fromCharCode(letter) == str)
			{
				hit = true;
			}

			if (_selected.contains(String.fromCharCode(letter)))
			{
				sb.add(String.fromCharCode(letter));
			}
			else
			{
				sb.add("*");
			}
		}

		if (hit == false)
		{
			turns--;
			if (turns > 0)
			{
				hangman.loadGraphic("assets/images/hangman" + Std.string(turns) + ".png");
			}
		}

		guessed.text = sb.toString();
		if (guessed.text.indexOf("*") == -1)
		{
			correct = true;
			reset = new FlxButton(100, FlxG.height - 75, "Next level?", resetCallback.bind(lev + 1));
			add(reset);
		}
		else if (turns == 0)
		{
			hangman.loadGraphic("assets/images/hangman" + Std.string(turns) + ".png");
			guessed.text = word;
			guessed.color = FlxColor.RED;
			gameover = true;
			overtext = new FlxText(FlxG.width / 2, 120, "Game over!", 32);
			overtext.x -= overtext.width / 2;
			overtext.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.RED, 2, 1);
			add(overtext);
			reset = new FlxButton(FlxG.width / 2 - 40, 165, "Reset?", resetCallback.bind(1));
			add(reset);
		}
	}

	/**
	 * Resets the game state, either after a game over or advancing to a new level.
	 * @param rlev 	The level that the game state is proceeding to. 1 if a reset, >1 otherwise.
	 */
	function resetCallback(rlev:Int):Void
	{
		correct = false;
		gameover = false;
		turns = 9;
		hangman.loadGraphic("assets/images/hangman" + Std.string(turns) + ".png");
		if (overtext != null)
		{
			overtext.destroy();
		}
		reset.destroy();
		guessed.color = FlxColor.WHITE;
		lev = rlev;
		_selected = new Array<String>();
		word = genWord();
		guessed.text = "********";
		levtext.text = "Level: " + Std.string(lev);
		for (t in _tiles)
		{
			t.label.color = FlxColor.WHITE;
		}
	}

	/**
	 * Picks a random eight-letter word from the dictionary.
	 * @return String	The random word that is retrieved.
	 */
	function genWord():String
	{
		var rand = Std.int(Math.random() * _dictionary.length);
		return _dictionary[rand];
	}

	/**
	 * Fills the dictionary array with the contents of dictionary.txt. Should only be
	 * called once!
	 */
	function fillDictionary():Void
	{
		var lines:Array<String> = Assets.getText("assets/data/dictionary.txt").split("\n");
		var line:String = null;
		for (v in lines)
		{
			line = StringTools.replace(v, "\r", "");
			_dictionary.push(line);
		}
	}
}
