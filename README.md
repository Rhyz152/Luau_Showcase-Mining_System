# **NOTE: Not all scripts are shown for security reasons**
# *Info*
This is a showcase of a mining system programmed by Rhyz152.
In the background, Module loaders are used to make a modular framework, if you see a Start() function, that means it runs in immediately.
This project uses the following packages: ByteNet (original, by ffrostfall)
It is recommended to read through the scripts, important sections are commented on.
**I won't document every script as it is pointless and quite easy to know what it is doing by reading it**

# *Pickaxe System*
The player is required to have a pickaxe for the mining system to work.

### Pickaxe Equip function
This is the main function for the entire system.
We determine whether the player already has a pickaxe by checking if _HasPickaxe is true or its found inside their character.
If not, we clone a new pickaxe and parent it to the player's character.
We then get the pickaxe's handle's Motor6D and stored CFrameValue.
We then set the Motor6D's Part0 to the Right Arm of the player's character and Part1 to the pickaxe's handle.
This allows it to go to the right arm of the player.
We then set the Motor6D's CFrame1 value to the stored CFrameValue (moves the handle to the right position and orientation).
Finally, we set the _HasPickaxe to true.
When the player dies or leaves, we destroy the pickaxe and set it to nil, and then its created again.

### Pickaxe Activate function
This function allows the player to utilize the Pickaxe.
We do a quick check on the client to see if they are on cooldown and stop if they are.
The script proceeds to play an animation for quick feedback to client
When the animation event is reached, a remote event to the server is fired to handle spatial query hitboxes and actual cooldown logic.
After the server does everything it needs to, it would send a buffer signal to the client (using the ByteNet library) which has data including the hit rock's CFrame.
We use this CFrame to play Vfx and set the Vfx's part's CFrame to the hit rock's CFrame.
The Sfx and Vfx use **Object Pooling** to optimize game performance.
The *Object Pool* section will explain the object pooling, if you are unaware of what it is.

# *Mining System*
This is the core system of the game of course.

The server listens for the remote event that would be fired from the pickaxe activate function.
When it is fired, the server validates cooldown and if they are on cooldown, it stops the function, the client plays the animation still but nothing happens.
Using a object pool for the hitbox, we get the actual created object from the object pool and set the properties.
While the rest of the script runs, after .25s, the hitbox is freed if it exists.
We then use workspace:GetPartsBoundInBox(...) method to spatial query everything in the hitbox.
Using collection service, we get all the tags of the Part.
Using a for loop to check if in the tags is the "Rock" tag.
This allows us to create multiple rocks with same logic, one script.
If there is, we set AlreadyHit[Part] to true so its not queried again in the same loop.
We then check if it has been hit, if not, then it sets it to 1.
If it has been hit, then it increments by 1.
After being hit 3 times, we destroy the part and set the HitTimes[Part] to nil and communicate to the DataService to add rocks to the client's data.
Finally, we use the ByteNet library to send in the CframeVal as the part's cframe value, optimized and goes to the client.

# *Object Pool*
To ensure this project is optimized, I used an object pool script.

### What it is
Instead of continuously cloning and parenting objects a lot of times, which cost a lot of resources (very un-optimized), an object pool creates/clones it and parents it once, then disables it when freed or unparents it.
If you see an object pool function in any of the scripts, you'd see an OnCreate and OnFree function.
The OnCreate function initializes the object by parenting it after it gets created/cloned via the object pool utility.
The OnFree function either disables or enables the object or its properties, if its a sound then it would probably Stop() it or unparent it, depends on use case.
