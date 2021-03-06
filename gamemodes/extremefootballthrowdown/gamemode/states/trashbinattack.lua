STATE.Time = 0.75

function STATE:Started(pl, oldstate)
	pl:ResetJumpPower(0)
end

if SERVER then
function STATE:Ended(pl, newstate)
	if newstate == STATE_NONE then
		local carry = pl:GetCarry()
		if not carry:IsValid() or carry:GetClass() ~= "prop_carry_trashbin" then return end

		for _, tr in ipairs(pl:GetTargets()) do
			local hitent = tr.Entity
			if hitent:IsPlayer() then
				local ent = ents.Create("prop_trashbin")
				if ent:IsValid() then
					ent:SetPos(hitent:EyePos())
					ent:SetOwner(hitent)
					ent:SetParent(hitent)
					ent:Spawn()
				end

				hitent:TakeDamage(1, pl, carry)

				carry:Remove()

				return
			end
		end
	end
end
end

function STATE:IsIdle(pl)
	return false
end

function STATE:Move(pl, move)
	move:SetSideSpeed(0)
	move:SetForwardSpeed(0)
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)

	return MOVE_STOP
end

function STATE:Think(pl)
	if not pl:IsOnGround() and pl:WaterLevel() < 2 then
		pl:EndState(true)
	end
end

function STATE:CalcMainActivity(pl, velocity)
	pl.CalcSeqOverride = pl:LookupSequence("seq_preskewer")
end

function STATE:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	pl:SetCycle(math.Clamp((pl:GetStateEnd() - CurTime()) / self.Time, 0, 1) ^ 2 * 0.85 + 0.15)
	pl:SetPlaybackRate(0)

	return true
end
