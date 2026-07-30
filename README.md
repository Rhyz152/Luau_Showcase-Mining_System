# **NOTE: Not all scripts are shown for security reasons**
# *Info*
This is a showcase of a mining system programmed by Rhyz152.
In the background, Module loaders are used to make a modular framework.
It is recommended to read through the scripts, important sections are commented on.

# *Pickaxe System*
The player is required to have a pickaxe for the mining system to work.
A function is programmed to clone a model asset of the pickaxe to the player.
### Pickaxe Pool
To avoid unnecessary cloning and parenting, which is inefficient and can cause lag over long sessions, we use a **Object Pool**.
If you do not know what an object pool is, the *Object Pool* section will explain it to you.
We check if there already is a object pool for the pickaxe and return the already existing object pool if there is.
By doing that, it avoids 
