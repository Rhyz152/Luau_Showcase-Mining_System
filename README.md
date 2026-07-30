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
By doing this, it avoids the problem of continuing to create new pools.
After the OnCreate and OnFree functions, we actually construct the object via the ObjectPoolHandler and we return the class object.
### Pickaxe Equip function
This is the main function for the entire system.
We determine whether the player already has a pickaxe by checking if _HasPickaxe is true or its found inside their character.
If not, then we get the class object pool and by that, we can get the actual object of the pool by using the :Get() function in the class object pool.
We then get the children inside the actual object, with the main ones being the Motor6D and the stored CFrameValue inside of the Handle part of the pickaxe.
We set Part0 of the Motor6D to the Right Arm of the player's Character and Part1 to the Handle of the Pickaxe.
This allows it to move to the Right Arm.
We use the stored CFrameValue's value and set the cframe of the Motor6D's Part1's cframe (the handle) with the stored cframe value (that wasn't worded the best, essentially, gets stored cframe value and via the Motor6D the handle's cframe goes to the stored cframe value).
We then set _HasPickaxe to true.
To cleanup, we check if either the humanoid has died or the player has left.
If so, we use the class object pool and use the :Free function and send in the actual object.
### Pickaxe Activate function
This function allows the player to utilize the Pickaxe
We do a quick check on the client to see if they are on cooldown and 

((( Gone ))))


# *Mining System*
