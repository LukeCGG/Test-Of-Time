extends Node
## Signals accessed by instanced nodes

@warning_ignore("unused_signal")
signal playerHit(damage) ## Triggered when player hit by enemy[br]Causes player death
@warning_ignore("unused_signal")
signal playerDied ## Triggered after player has run out of life and places statue
@warning_ignore("unused_signal")
signal newGeneration ## Triggered when player respawns and starts new chalk
