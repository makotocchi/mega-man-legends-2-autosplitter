// MML2 Emulator Auto Splitter
// Made by apel

state("duckstation-qt-x64-ReleaseLTCG") 
{
}
state("PPSSPPWindows64")
{
    long baseAddress : 0xD96108;
}

startup
{
    settings.Add("timer_settings", true, "Timer Settings");
    settings.SetToolTip("timer_settings", "Settings related to the timer");

    settings.Add("split_settings", true, "Split Settings");
    settings.SetToolTip("split_settings", "Settings related to auto splitting");

    settings.CurrentDefaultParent = "timer_settings";

    settings.Add("igt_timer_start", true, "Start timer when IGT starts");
    settings.SetToolTip("igt_timer_start", "If disabled, it starts the timer when the RTA timer normally would start");

    settings.Add("ignore_igt", false, "Ignore IGT");
    settings.SetToolTip("ignore_igt", "If enabled, Livesplit will ignore the in-game timer, but it will still stop the timer when the game is loading (useful for testing strats)");

    settings.Add("area_change_start", false, "Start timer when the area changes");
    settings.SetToolTip("area_change_start", "If enabled, it starts the timer when the area changes");

    settings.CurrentDefaultParent = "split_settings";

    settings.Add("area_split", false, "Split whenever the area changes");
    settings.SetToolTip("area_split", "Split whenever you go to a different area, even if it doesn't stop IGT. The settings below will be ignored in case this is checked. (WARNING: not recommended for full game runs)");

    settings.Add("abandoned_mines", true, "Abandoned Mines");
    settings.SetToolTip("abandoned_mines", "Split when you complete Abandoned Mines");

    settings.Add("forbidden_island", true, "Forbidden Island");
    settings.SetToolTip("forbidden_island", "Split when you complete Forbidden Island");

    settings.Add("crab_battle", true, "Crab Battle");
    settings.SetToolTip("crab_battle", "Split when you complete the Crab Battle");

    // settings.Add("bola_battle_1", false, "Bola Battle 1");
    // settings.SetToolTip("bola_battle_1", "Split when you leave Bola 1's room");

    // settings.Add("bola_battle_2", false, "Bola Battle 2");
    // settings.SetToolTip("bola_battle_2", "Split when you leave Bola 2's room");

    settings.Add("manda_ruins", true, "Manda Ruins");
    settings.SetToolTip("manda_ruins", "Split when you complete Manda Ruins");

    settings.Add("quiz", false, "Quiz");
    settings.SetToolTip("quiz", "Split when you leave the mayor's house in Manda (it doesn't check if you have completed the quizzes)");

    settings.Add("pokte_caverns", false, "Pokte Caverns");
    settings.SetToolTip("pokte_caverns", "Split when you leave Pokte Caverns with the refractor");

    settings.Add("nino_invasion", true, "Nino Invasion");
    settings.SetToolTip("nino_invasion", "Split when you complete the Nino Invasion");

    settings.Add("kito_caverns", false, "Kito Caverns");
    settings.SetToolTip("kito_caverns", "Split when you leave Kito Caverns with the refractor");

    settings.Add("glyde_base", true, "Glyde's Base");
    settings.SetToolTip("glyde_base", "Split when you complete Glyde's Base");

    settings.Add("nino_ruins", true, "Nino Ruins");
    settings.SetToolTip("nino_ruins", "Split when you complete Nino Ruins");

    settings.Add("kimotama_caverns", false, "Kimotama Caverns");
    settings.SetToolTip("kimotama_caverns", "Split when you leave Kimotama Caverns with the refractor");

    settings.Add("kimotama_city", true, "Kimotama City");
    settings.SetToolTip("kimotama_city", "Split when you complete Kimotama City");

    settings.Add("saul_kada_ruins", true, "Saul Kada Ruins");
    settings.SetToolTip("saul_kada_ruins", "Split when you complete Saul Kada Ruins");

    settings.Add("train_battle", true, "Train Battle");
    settings.SetToolTip("train_battle", "Split when you complete the Train Battle");

    settings.Add("calinca_ruins", true, "Calinca Ruins");
    settings.SetToolTip("calinca_ruins", "Split when you complete Calinca Ruins");

    settings.Add("geetz_battle", false, "Geetz Battle");
    settings.SetToolTip("geetz_battle", "Split when you complete the Geetz Battle");

    settings.Add("defense_zone", false, "Defense Zone");
    settings.SetToolTip("defense_zone", "Split when you complete the Defense Zone");

    settings.Add("elysium", true, "Elysium");
    settings.SetToolTip("elysium", "Split when you complete Elysium (Residential Area)");

    settings.Add("boss_rush", true, "Boss Rush");
    settings.SetToolTip("boss_rush", "Split when you complete the Boss Rush");

    settings.Add("igt_screen", true, "IGT Screen");
    settings.SetToolTip("igt_screen", "Split when you reach the final IGT Screen");

    settings.CurrentDefaultParent = null;

    // ASL Var Viewer Things
    vars.Zenny = 0;
    vars.Karma = 0;
    vars.RollKarma = 0;
    vars.NinoInvasionTimer = 0;

    vars.TrainBattleCounter = 0;
    vars.IGTStarted = false;
    vars.IGTWhenTimerStarted = 0;

    vars.OnReset = (LiveSplit.Model.Input.EventHandlerT<TimerPhase>)((sender, e) => 
    {
        vars.TrainBattleCounter = 0;
        vars.IGTStarted = false;
        vars.IGTWhenTimerStarted = 0;
    });
    timer.OnReset += vars.OnReset;

    vars.OnStart = (EventHandler)((sender, e) => {
        vars.TrainBattleCounter = 0;
        vars.IGTStarted = vars.Memory["Area"].Current != 0x0039 || (vars.Memory["Area"].Current == 0x0039 && vars.Memory["IGT"].Current > vars.Memory["IGT"].Old);
        vars.IGTWhenTimerStarted = vars.Memory["IGT"].Current;
    });
    timer.OnStart += vars.OnStart;
}

shutdown
{
    timer.OnStart -= vars.OnStart;
    timer.OnReset -= vars.OnReset;
}

init
{
    var processName = game.ProcessName.ToLowerInvariant();

    if (processName.Contains("duckstation")) 
    {
        version = "DuckStation " + modules.First().FileVersionInfo.FileVersion;
        vars.BaseAddress = IntPtr.Zero;
        vars.GameIdWatcher = null;
    }
    else
    {
        version = "PPSSPP " + modules.First().FileVersionInfo.FileVersion;
    }

    vars.Memory = null;
}

exit
{
    vars.Zenny = 0;
    vars.Karma = 0;
    vars.RollKarma = 0;
    vars.NinoInvasionTimer = 0;
    vars.TrainBattleCounter = 0;
    vars.IGTStarted = false;
    vars.IGTWhenTimerStarted = 0;
    vars.Memory = null;

    if (version.StartsWith("DuckStation"))
    {
        vars.GameIdWatcher = null;
        vars.BaseAddress = IntPtr.Zero;
    }
}

update
{
    if (string.IsNullOrEmpty(version)) 
    {
        return false;
    }

    if (version.StartsWith("DuckStation")) 
    {
        if (vars.BaseAddress == IntPtr.Zero) 
        {
            foreach (var page in game.MemoryPages(true)) 
            {
                if ((page.RegionSize == (UIntPtr)0x200000) && (page.Type == MemPageType.MEM_MAPPED))
                {
                    vars.BaseAddress = page.BaseAddress;
                    break;
                }
            }

            if (vars.BaseAddress != IntPtr.Zero)
            {
                vars.GameIdWatcher = new StringWatcher(new IntPtr((long)vars.BaseAddress + 0x925C), 11);
            }
        }


        if (vars.GameIdWatcher != null)
        {
            vars.GameIdWatcher.Update(game);

            if (vars.GameIdWatcher.Current != vars.GameIdWatcher.Old) 
            {
                if (vars.GameIdWatcher.Current == "SLUS_011.40")
                {
                    print("SLUS_011.40");
                    print("Base Address: " + ((long)vars.BaseAddress).ToString("X"));

                    vars.Memory = new MemoryWatcherList();
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9C808)) { Name = "Area" });
                    vars.Memory.Add(new MemoryWatcher<int>(new IntPtr((long)vars.BaseAddress + 0x9C818)) { Name = "IGT" });
                    vars.Memory.Add(new MemoryWatcher<int>(new IntPtr((long)vars.BaseAddress + 0x9C810)) { Name = "Final IGT" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9C816)) { Name = "Game Complete" });
                    vars.Memory.Add(new MemoryWatcher<byte>(new IntPtr((long)vars.BaseAddress + 0x985D1)) { Name = "Refractors" });
                    vars.Memory.Add(new MemoryWatcher<int>(new IntPtr((long)vars.BaseAddress + 0x9C820)) { Name = "Zenny" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9C838)) { Name = "Karma" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9C83A)) { Name = "Roll Karma" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9E620)) { Name = "Nino Invasion Timer 1" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9E660)) { Name = "Nino Invasion Timer 2" });

                    vars.Memory.UpdateAll(game);
                }
                else if (vars.GameIdWatcher.Current == "SLPS_027.11")
                {
                    print("SLPS_027.11");
                    print("Base Address: " + ((long)vars.BaseAddress).ToString("X"));

                    vars.Memory = new MemoryWatcherList();
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9CAB0)) { Name = "Area" });
                    vars.Memory.Add(new MemoryWatcher<int>(new IntPtr((long)vars.BaseAddress + 0x9CAC0)) { Name = "IGT" });
                    vars.Memory.Add(new MemoryWatcher<int>(new IntPtr((long)vars.BaseAddress + 0x9CAB8)) { Name = "Final IGT" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9CABE)) { Name = "Game Complete" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x98879)) { Name = "Refractors" });
                    vars.Memory.Add(new MemoryWatcher<int>(new IntPtr((long)vars.BaseAddress + 0x9CAC8)) { Name = "Zenny" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9CAE0)) { Name = "Karma" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9CAE2)) { Name = "Roll Karma" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9E8C8)) { Name = "Nino Invasion Timer 1" });
                    vars.Memory.Add(new MemoryWatcher<short>(new IntPtr((long)vars.BaseAddress + 0x9E908)) { Name = "Nino Invasion Timer 2" });
                    
                    vars.Memory.UpdateAll(game);
                }
                else
                {
                    vars.Memory = null;
                    vars.GameIdWatcher = null;
                    vars.BaseAddress = IntPtr.Zero;
                }
            }
        }
    }
    else
    {
        if (vars.Memory == null && current.baseAddress != 0x0)
        {
            print("PSP");
            print("Base Address: " + current.baseAddress.ToString("X"));

            vars.Memory = new MemoryWatcherList();
            vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x8DADD0C)) { Name = "Area" });
            vars.Memory.Add(new MemoryWatcher<int>(new IntPtr(current.baseAddress + 0x8DADD1C)) { Name = "IGT" });
            vars.Memory.Add(new MemoryWatcher<int>(new IntPtr(current.baseAddress + 0x8DADD14)) { Name = "Final IGT" });
            vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x8DADD1A)) { Name = "Game Complete" });
            vars.Memory.Add(new MemoryWatcher<byte>(new IntPtr(current.baseAddress + 0x9057EC9)) { Name = "Refractors" });
            vars.Memory.Add(new MemoryWatcher<int>(new IntPtr(current.baseAddress + 0x8DADD24)) { Name = "Zenny" });
            vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x8DADD3C)) { Name = "Karma" });
            vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x8DADD3E)) { Name = "Roll Karma" });
            vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x902E0CC)) { Name = "Nino Invasion Timer 1" });
            vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x902E10C)) { Name = "Nino Invasion Timer 2" });

            vars.Memory.UpdateAll(game);
        }
        else if (current.baseAddress == 0x0)
        {
            vars.Memory = null;
        }
    }

    if (vars.Memory == null) 
    {
        return false;
    }

    vars.Memory.UpdateAll(game);

    if (!vars.IGTStarted)
    {
        vars.IGTStarted = vars.Memory["Area"].Current != 0x0039 || (vars.Memory["Area"].Current == 0x0039 && vars.Memory["IGT"].Current > vars.Memory["IGT"].Old);
    }

    vars.Zenny = vars.Memory["Zenny"].Current;
    vars.Karma = vars.Memory["Karma"].Current;
    vars.RollKarma = vars.Memory["Roll Karma"].Current;
    
    if (vars.Memory["Area"].Current == 0x0016)
    {
        vars.NinoInvasionTimer = vars.Memory["Nino Invasion Timer 1"].Current;
    }
    else if (vars.Memory["Area"].Current == 0x0015)
    {
        vars.NinoInvasionTimer = vars.Memory["Nino Invasion Timer 2"].Current;
    }
    else
    {
        vars.NinoInvasionTimer = 0;
    }

    return true;
}

isLoading
{
    return true;
}

gameTime
{
    if (settings["ignore_igt"])
    {
        return TimeSpan.FromSeconds((vars.Memory["IGT"].Current - vars.IGTWhenTimerStarted) / 60.0D);
    }

    if (!vars.IGTStarted)
    {
        return TimeSpan.FromSeconds(0);
    }

    return TimeSpan.FromSeconds(vars.Memory["IGT"].Current / 60.0D);
}

start
{
    if (settings["area_change_start"])
    {
        return vars.Memory["Area"].Old != vars.Memory["Area"].Current;
    }

    if (settings["igt_timer_start"])
    {
        return vars.Memory["Area"].Current == 0x0039 && vars.Memory["IGT"].Current > vars.Memory["IGT"].Old && vars.Memory["IGT"].Old == 0;
    }
    
    return vars.Memory["Area"].Current == 0x0039 && vars.Memory["Area"].Current != vars.Memory["Area"].Old;
}


split
{
    if (settings["area_split"])
    {
        return vars.Memory["Area"].Old != vars.Memory["Area"].Current;
    }

    if (settings["abandoned_mines"] && vars.Memory["Area"].Old == 0x0B0F && vars.Memory["Area"].Current == 0x0247) // complete abandoned mine
    {
        return true;
    }

    if (settings["forbidden_island"] && vars.Memory["Area"].Old == 0x021D && vars.Memory["Area"].Current == 0x001C) // complete forbidden islands
    {
        return true;
    }

    if (settings["crab_battle"] && vars.Memory["Area"].Old == 0x0625 && vars.Memory["Area"].Current == 0x0025) // beat crab
    {
        return true;
    }

    // if (settings["bola_battle_1"] && !vars.BolaBattle1Done && vars.Memory["Area"].Old == 0x0113 && vars.Memory["Area"].Current == 0x0213) // beat bola 1
    // {
    //     vars.BolaBattle1Done = true;
    //     return true;
    // }

    // if (settings["bola_battle_2"] && vars.Memory["Area"].Old == 0x0512 && vars.Memory["Area"].Current == 0x0412) // beat bola 2
    // {
    //     return true;
    // }

    if (settings["manda_ruins"] && vars.Memory["Area"].Old == 0x0414 && vars.Memory["Area"].Current == 0x0124) // beat manda ruins
    {
        return true;
    }

    if (settings["quiz"] && vars.Memory["Area"].Old == 0x0032 && vars.Memory["Area"].Current == 0x0124) // quiz done
    {
        return true;
    }

    if (settings["pokte_caverns"] && vars.Memory["Area"].Old == 0x004E && vars.Memory["Area"].Current == 0x0024 && (vars.Memory["Refractors"].Current & 0x20) == 0x20) // leave pokte caverns with the refractor
    {
        return true;
    }

    if (settings["nino_invasion"] && vars.Memory["Area"].Old == 0x0018 && vars.Memory["Area"].Current == 0x0019) // beat nino invasion
    {
        return true;
    }

    if (settings["kito_caverns"] && vars.Memory["Area"].Old == 0x004F && vars.Memory["Area"].Current == 0x0022 && (vars.Memory["Refractors"].Current & 0x40) == 0x40) // leave kito caverns with the refractor
    {
        return true;
    }

    if (settings["glyde_base"] && vars.Memory["Area"].Old == 0x0230 && vars.Memory["Area"].Current == 0x001F) // complete glyde's base
    {
        return true;
    }

    if (settings["nino_ruins"] && vars.Memory["Area"].Old == 0x0035 && vars.Memory["Area"].Current == 0x0119) // complete nino ruins
    {
        return true;
    }

    if (settings["kimotama_city"] && vars.Memory["Area"].Old == 0x023C && vars.Memory["Area"].Current == 0x0026) // complete kimotama city
    {
        return true;
    }

    if (settings["kimotama_caverns"] && vars.Memory["Area"].Old == 0x0050 && vars.Memory["Area"].Current == 0x0148 && (vars.Memory["Refractors"].Current & 0x80) == 0x80) // leave kimotama caverns with the refractor
    {
        return true;
    }

    if (settings["saul_kada_ruins"] && vars.Memory["Area"].Old == 0x0028 && vars.Memory["Area"].Current == 0x023C) // complete saul kada ruins
    {
        return true;
    }

    if (settings["train_battle"] && vars.Memory["Area"].Old == 0x020E && vars.Memory["Area"].Current == 0x0153) // beat train
    {
        vars.TrainBattleCounter++;
        return vars.TrainBattleCounter >= 2; // the train battle has two phases, it should only split after the second one
    }

    if (settings["calinca_ruins"] && vars.Memory["Area"].Old == 0x072F && vars.Memory["Area"].Current == 0x010B) // complete calinca ruins
    {
        return true;
    }

    if (settings["geetz_battle"] && vars.Memory["Area"].Old == 0x054B && vars.Memory["Area"].Current == 0x0052) // beat geetz
    {
        return true;
    }

    if (settings["defense_zone"] && vars.Memory["Area"].Old == 0x0D42 && vars.Memory["Area"].Current == 0x0240) // complete the defense zone
    {
        return true;
    }

    if (settings["elysium"] && vars.Memory["Area"].Old == 0x0056 && vars.Memory["Area"].Current == 0x0043) // complete elysium
    {
        return true;
    }

    if (settings["boss_rush"] && vars.Memory["Area"].Old == 0x0545 && vars.Memory["Area"].Current == 0x004C) // beat boss rush
    {
        return true;
    }

    if (settings["igt_screen"] && vars.Memory["Game Complete"].Current > vars.Memory["Game Complete"].Old) // IGT stops
    {
        return true;
    }

    return false;
}