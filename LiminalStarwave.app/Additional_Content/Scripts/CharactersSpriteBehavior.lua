local currentAnim = ""
function Idle()
	currentAnim = "ENAIdle"
	Object.SpriteBehaviorAnimation.Play(currentAnim)
end

function Left()
	currentAnim = "ENALeft"
	Object.SpriteBehaviorAnimation.Play(currentAnim)
end
function Right()
	currentAnim = "ENARight"
	Object.SpriteBehaviorAnimation.Play(currentAnim)
end
function Down()
	currentAnim = "ENADown"
	Object.SpriteBehaviorAnimation.Play(currentAnim)
end
function Up()
	currentAnim = "ENAUp"
	Object.SpriteBehaviorAnimation.Play(currentAnim)
end

function ChangeSprite(index)
	Object.Render.setImage(currentAnim .. index .. ".pic")
end

function OnEndNotIdle()
	OE.Script.Invoke(Idle, 0.2)
end

Start = Idle

function Init()
	Object:_addScript('MAIN_Animation.lua','SpriteBehaviorAnimation', true)
	Object.SpriteBehaviorAnimation.animations["ENAIdle"] = {
		onEnd = Idle,
		frames = {
			[0] = ChangeSprite,
			[0.2] = ChangeSprite,
			[0.4] = ChangeSprite
		}
	}
	Object.SpriteBehaviorAnimation.animations["ENAUp"] = {
		onEnd = OnEndNotIdle,
		frames = {
			[0] = ChangeSprite,
			[0.1] = ChangeSprite
		}
	}
	Object.SpriteBehaviorAnimation.animations["ENADown"] = Object.SpriteBehaviorAnimation.animations["ENAUp"]
	Object.SpriteBehaviorAnimation.animations["ENALeft"] = Object.SpriteBehaviorAnimation.animations["ENAUp"]
	Object.SpriteBehaviorAnimation.animations["ENARight"] = Object.SpriteBehaviorAnimation.animations["ENAUp"]
end