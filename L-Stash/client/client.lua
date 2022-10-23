local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
		PlayerData = ESX.GetPlayerData()
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)
--Locatie's van stash
--Zet er zoveel als je wil maar vegeet je , niet weg te halen bij de onderste locatie
local stash = {
   {x = -322.05,y = -322.96,z = 30.72},
   --{x = -325.54,y = -323.32,z = 30.72}
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k in pairs(stash) do
            DrawMarker(31, stash[k].x, stash[k].y, stash[k].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 0, 230, 255, 100, false, true, 2, true, false, false, false)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for k in pairs(stash) do
		
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, stash[k].x, stash[k].y, stash[k].z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.3, 0.3, 0.2, 0, 230, 255, 100, false, true, 2, true, false, false, false)

            if dist <= 0.5 then
				hintToDisplay('Klik op ~INPUT_CONTEXT~ voor ~b~stash~w~ te opene')
				
				if IsControlJustPressed(0, Keys['E']) then 
					if IsPedInAnyVehicle(GetPlayerPed(-1)) then
						ESX.ShowNotification("Je hebt Geen ~r~Kleren")
					else
						Openstash()
					end
				end			
            end
        end
    end
end)

function Openstash()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'ClothesStashCollection',
        {
            title    = "stash",
            align    = "top-right",
            elements = {
				{ ["label"] = "KlerenKast", ["type"] = "clothes" },
                { ["label"] = "Kleding verwijderen", ["type"] = "remove_cloth" },
                { ["label"] = "Spullen Wegleggen", ["type"] = "player_inventory" },
                { ["label"] = "Spullen Pakken", ["type"] = "room_inventory" }
            }

        }, function(data, menu)

         local type = data.current.type

         if type == 'clothes' then
            
            ESX.TriggerServerCallback('esx_property:getPlayerDressing', function(dressing)
               local elements = {}

               for i = 1, #dressing, 1 do
                  table.insert(elements, {
                     label = dressing[i],
                     value = i
                  })
               end

               ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing', {
                  title = "mijn kleren",
                  align = "top-right",
                  elements = elements
               }, function(data2, menu2)

                  TriggerEvent('skinchanger:getSkin', function(skin)
                     ESX.TriggerServerCallback('esx_property:getPlayerOutfit', function(clothes)
                        TriggerEvent('skinchanger:loadClothes', skin, clothes)
                        TriggerEvent('esx_skin:setLastSkin', skin)

                        TriggerEvent('skinchanger:getSkin', function(skin)
                           TriggerServerEvent('esx_skin:save', skin)
                        end)
                     end, data2.current.value)
                  end)
               end, function(data2, menu2)
                  menu2.close()
               end)
            end)

         elseif type == 'remove_cloth' then
            
            ESX.TriggerServerCallback('esx_property:getPlayerDressing', function(dressing)
               local elements = {}

               for i = 1, #dressing, 1 do
                  table.insert(elements, {
                     label = dressing[i],
                     value = i
                  })
               end

               ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'remove_cloth', {
                  title = "verwijder kleren",
                  align = "top-right",
                  elements = elements
               }, function(data2, menu2)
                  menu2.close()
                  TriggerServerEvent('esx_property:removeOutfit', data2.current.value)
                  ESX.ShowNotification('De outfit is uit je Klerenkast gehaald!.')
               end, function(data2, menu2)
                  menu2.close()
               end)
            end)

         elseif type == 'player_inventory' then
            
            OpenPlayerInventoryMenu(CurrentActionData, ESX.GetPlayerData().identifier)

         elseif type == 'room_inventory' then
            
            OpenRoomInventoryMenu(CurrentActionData, ESX.GetPlayerData().identifier)

         end
   
   end, function(data, menu)
      menu.close()
   end)
end

function OpenPlayerInventoryMenu(property, owner)

   ESX.TriggerServerCallback('esx_property:getPlayerInventory', function(inventory)
      local elements = {}

      if inventory.blackMoney > 0 then
         table.insert(elements, {
            label = 'ZwartGeld: <span style = "color: red;">'.. ESX.Math.GroupDigits(inventory.blackMoney) ..'</span>',
            type  = 'item_account',
            value = 'black_money'
         })
      end

      for i = 1, #inventory.items, 1 do
         local item = inventory.items[i]

         if item.count > 0 then
            table.insert(elements, {
               label = item.label .. ' x' .. item.count,
               type  = 'item_standard',
               value = item.name
            })
         end
      end

      for i = 1, #inventory.weapons, 1 do
         local weapon = inventory.weapons[i]

         table.insert(elements, {
            label = weapon.label .. ' [' .. weapon.ammo .. ']',
            type  = 'item_weapon',
            value = weapon.name,
            ammo  = weapon.ammo
         })
      end

      ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_inventory', {
         title = "inventory",
         align = "top-right",
         elements = elements
      }, function(data, menu)

         if data.current.type == 'item_weapon' then
            menu.close()
            TriggerServerEvent('esx_property:putItem', owner, data.current.type, data.current.value, data.current.ammo)

            ESX.SetTimeout(300, function()
               OpenPlayerInventoryMenu(property, owner)
            end)
         else
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_count', {
               title = 'Aantal?'
            }, function(data2, menu2)
               local quantity = tonumber(data2.value)

               if quantity == nil then
                  ESX.ShowNotification('Ongeldige hoeveelheid')
               else
                  menu2.close()
                  TriggerServerEvent('esx_property:putItem', owner, data.current.type, data.current.value, tonumber(data2.value))
                  ESX.SetTimeout(300, function()
                     OpenPlayerInventoryMenu(property, owner)
                  end)
               end
            end, function(data2, menu2)
               menu2.close()
            end)
         end
      end, function(data, menu)
         menu.close()
      end)
   end)

end
                    
function OpenRoomInventoryMenu(property, owner)

   ESX.TriggerServerCallback('esx_property:getPropertyInventory', function(inventory)
      local elements = {}

      if inventory.blackMoney > 0 then
         table.insert(elements, {
            label = 'ZwartGeld: <span style = "color: red;">'.. ESX.Math.GroupDigits(inventory.blackMoney) ..'</span>',
            type  = 'item_account',
            value = 'black_money'
         })
      end

      for i = 1, #inventory.items, 1 do
         local item = inventory.items[i]

         if item.count > 0 then
            table.insert(elements, {
               label = item.label .. ' x' .. item.count,
               type  = 'item_standard',
               value = item.name
            })
         end
      end

      for i = 1, #inventory.weapons, 1 do
         local weapon = inventory.weapons[i]

         table.insert(elements, {
            label = ESX.GetWeaponLabel(weapon.name) .. ' [' .. weapon.ammo .. ']',
            type  = 'item_weapon',
            value = weapon.name,
            ammo  = weapon.ammo
         })
      end

      ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'room_inventory', {
         title = "Inventory",
         align = "top-right",
         elements = elements
      }, function(data, menu)

         if data.current.type == 'item_weapon' then
            menu.close()
            TriggerServerEvent('esx_property:getItem', owner, data.current.type, data.current.value, data.current.ammo)
            ESX.SetTimeout(300, function()
               OpenRoomInventoryMenu(property, owner)
            end)
         else
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'get_item_count', {
               title = 'Aantal?'
            }, function(data2, menu)
               local quantity = tonumber(data2.value)

               if quantity == nil then
                  ESX.ShowNotification('Ongeldige Hoeveelheid')
               else
                  menu.close()
                  TriggerServerEvent('esx_property:getItem', owner, data.current.type, data.current.value, quantity)
                  ESX.SetTimeout(300, function()
                     OpenRoomInventoryMenu(property, owner)
                  end)
               end
            end, function(data2, menu)
               menu.close()
            end)
         end
      end, function(data, menu)
         menu.close()
      end)
   end, owner)

end

function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end