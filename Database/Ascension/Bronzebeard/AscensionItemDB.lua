---@type table
local AscensionDB = QuestieLoader:CreateModule("AscensionDB")

AscensionDB.itemData = AscensionDB.itemData or {

		--Elwynn Forest

		[559159]={[1]="Oracular Idol",[2]={161717},[3]=nil,[4]=nil,[5]=1660036,[6]=nil,[7]=nil,[8]=nil,[9]=1,[10]=1,[11]=nil,[12]=nil,[13]=0},
		[5055565]={[1]="Tattered Orders",[2]={991516},[3]=nil,[4]=nil,[5]=100074,[6]=nil,[7]=nil,[8]=nil,[9]=1,[10]=1,[11]=nil,[12]=nil,[13]=0},
		[558956]={[1]="Elgris Blossom Petals",[2]=nil,[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=0,[10]=0,[11]=nil,[12]=12,[13]=0,[14]={162814},[15]={1660056}},
		[558957]={[1]="Dun Kazad Liquor Concentrate",[2]=nil,[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=0,[10]=0,[11]=nil,[12]=12,[13]=0,[14]={162811},[15]={1660056}},
		[558958]={[1]="Pumpkin Juice",[2]=nil,[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=0,[10]=0,[11]=nil,[12]=12,[13]=0,[14]={162809},[15]={1660056}},
		[558959]={[1]="Murloc Eyeball",[2]=nil,[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=0,[10]=0,[11]=nil,[12]=12,[13]=0,[14]={162826},[15]={1660056}},
		[558960]={[1]="Agria's Incomplete Potion",[2]=nil,[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=1,[10]=1,[11]=nil,[12]=15,[13]=0,[14]=nil,[15]={1660056}},
		[558961]={[1]="Pumpkin",[2]=nil,[3]={999014},[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=0,[10]=0,[11]=nil,[12]=0,[13]=5},
		[558962]={[1]="Melon",[2]=nil,[3]={999013},[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=0,[10]=0,[11]=nil,[12]=0,[13]=5},
		[558963]={[1]="Apple",[2]=nil,[3]={999015},[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=0,[10]=0,[11]=nil,[12]=0,[13]=5},
		[157001]={[1]="Gem Encrusted Spider Silk",[2]={43},[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=2048,[8]=nil,[9]=1,[10]=0,[11]=0,[12]=12,[13]=0,[14]=nil,[15]={17001}},
		[157006]={[1]="Simple Crystal Vial",[2]=nil,[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=0,[8]=nil,[9]=5,[10]=0,[11]=nil,[12]=12,[13]=0,[14]=nil,[15]={17003},[16]=157006},
		[157002]={[1]="Depleted Mana Gem",[2]={474},[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=1,[10]=1,[11]=nil,[12]=15,[13]=0,[14]=nil,[15]={17002}},
		[157007]={[1]="Gnoll Sword",[2]={97},[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=1,[10]=6,[11]=nil,[12]=15,[13]=0,[14]=nil,[15]={17004}},
		[157008]={[1]="Gnoll Axe",[2]={478},[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=1,[10]=10,[11]=nil,[12]=15,[13]=0,[14]=nil,[15]={17004}},
		[157012]={[1]="Smudged Note",[2]=nil,[3]=nil,[4]=nil,[5]=nil,[6]=nil,[7]=0,[8]=nil,[9]=1,[10]=1,[11]=nil,[12]=15,[13]=0,[14]=nil,[15]={17005}},
		[157014]={[1]="Mirror Lake Apple",[2]=nil,[3]={9017008},[4]=nil,[5]=nil,[6]=nil,[7]=nil,[8]=nil,[9]=1,[10]=8,[11]=nil,[12]=15,[13]=0,[14]=nil,[15]={17008}},

		--Teldrassil

		[559143] = {[1]="Cut of Good Meat",[3]={2300512},[9]=1,[10]=0,[12]=0,[13]=0,[15]={1660014}},
		[559144] = {[1]="Good Flesh Amalgam",[9]=1,[10]=0,[12]=12,[13]=0,[15]={1660015}},
		[559145] = {[1]="Blessed Good Flesh Amalgam",[15]={1660015}},

		--Durotar 

		[11584] = {'Cactus Apple Surprise',nil,nil,nil,nil,nil,nil,nil,5,0,0,4,0,nil,{254010}},  
		[254005] = {'Strange Flower',nil,{254001},nil,nil,nil,nil,nil,1,0,0,12,0,nil,{254008}},
		[254006] = {'Xaitoth\'s Blood',{254015},nil,nil,nil,nil,nil,nil,1,0,0,12,0,nil,nil},
		[559146] = {'Witch’s Amulet',nil,nil,nil,nil,nil,nil,nil,1,0,0,4,0,nil,{1660019}},
		[559148] = {'Bat Spiritual Essence',{161793},nil,nil,nil,nil,nil,nil,1,0,0,4,0,nil,{1660020}},
		[559149] = {'Spider Spiritual Essence',{161795},nil,nil,nil,nil,nil,nil,1,0,0,4,0,nil,{1660020}},
		[559150] = {'Serpent Spiritual Essence',{161794},nil,nil,nil,nil,nil,nil,1,0,0,4,0,nil,{1660020}},
		[559155] = {'Spiritual Unrest',{30719},nil,nil,nil,nil,nil,nil,0,0,0,4,0,nil,nil},
		[559158] = {'Unremarkable Stone',nil,nil,nil,nil,nil,nil,1,1,0,0,12,0,nil,nil},
		[559172] = {'Fire Elemental Shackles',nil,{1064805},nil,nil,nil,nil,nil,1,0,0,4,0,nil,{1660021}},
		[559173] = {'Earth Elemental Shackles',nil,{2392807},nil,nil,nil,nil,nil,1,0,0,4,0,nil,{1660021}},
		[559174] = {'Air Elemental Shackles',nil,{3478505},nil,nil,nil,nil,nil,1,0,0,4,0,nil,{1660021}},
		[559175] = {'Water Elemental Shackles',nil,{4541078},nil,nil,nil,nil,nil,1,0,0,4,0,nil,{1660021}},

		--Mulgore

		[559156] = {[1]="Grimtotem Marauder Mane",[2]={161809},[9]=0,[10]=0,[12]=12,[13]=0,[15]={1660030}},
		[559168] = {[1]="Offering Bone",[2]={161810},[3]={2300532},[9]=1,[10]=0,[12]=12,[13]=0,[15]={1660035}},
		[559151] = {[1]="Grimtotem Armor Piece",[3]={2300514},[9]=1,[10]=0,[12]=12,[13]=0,[15]={1660032}},
		[559152] = {[1]="Exalted Pendant",[3]={2300515},[9]=1,[10]=0,[12]=12,[13]=0,[15]={1660032}},
		[558972] = {[1]="Full Sanctuary Amphora",[3]={5195711},[15]={1660067}},
		[558971] = {[1]="Empty Sanctuary Amphora",[9]=1,[10]=0,[12]=12,[13]=0,[15]={1660067}},
		[558967] = {[1]="Holy Water Blessing",[9]=1,[10]=0,[12]=12,[13]=0,[15]={1660068}},
		[558968] = {[1]="Prairie Sap",[3]={2300552},[9]=0,[10]=0,[12]=0,[13]=0,[15]={1660069}},
		[558969] = {[1]="Kodo Tallow",[2]={162909,2972,2973,2974},[9]=0,[10]=0,[12]=12,[13]=0,[15]={1660069}},
		[662335] = {[1]="Ritual Totem",[2]={2965,2964},[9]=1,[10]=0,[12]=12,[13]=0,[15]={500004}},

		




}

AscensionItemDB=AscensionItemDB or {}
AscensionItemDB.itemData=AscensionDB.itemData
