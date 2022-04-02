// MML2 Emulator Auto Splitter
// Made by apel

state("duckstation-qt-x64-ReleaseLTCG") 
{
    long baseAddress : 0x6D96D8;
    string11 gameId : 0x6D96D8, 0x925C;
}
state("PPSSPPWindows64")
{
    long baseAddress : 0xD96108;
}

startup
{
    settings.Add("igt_timer_start", true, "Start timer when IGT starts");
    settings.SetToolTip("igt_timer_start", "If disabled, it starts the timer when the RTA timer normally would start");

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

    settings.Add("defense_zone", false, "Defense Zone");
    settings.SetToolTip("defense_zone", "Split when you complete the Defense Zone");

    settings.Add("elysium", true, "Elysium");
    settings.SetToolTip("elysium", "Split when you complete Elysium (Residential Area)");

    settings.Add("boss_rush", true, "Boss Rush");
    settings.SetToolTip("boss_rush", "Split when you complete the Boss Rush");

    settings.Add("igt_screen", true, "IGT Screen");
    settings.SetToolTip("igt_screen", "Split when you reach the final IGT Screen");

    vars.TrainBattleCounter = 0;
    vars.IGTStarted = false;
    vars.IGTStopped = false;

    vars.OnReset = (LiveSplit.Model.Input.EventHandlerT<TimerPhase>)((sender, e) => 
    {
        vars.TrainBattleCounter = 0;
        vars.IGTStarted = false;
        vars.IGTStopped = false;
    });
    timer.OnReset += vars.OnReset;

    vars.OnStart = (EventHandler)((sender, e) => {
        vars.TrainBattleCounter = 0;
        vars.IGTStarted = vars.Memory["Area"].Current != 0x0039 || (vars.Memory["Area"].Current == 0x0039 && vars.Memory["IGT"].Current > vars.Memory["IGT"].Old);
        vars.IGTStopped = false;
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
    }
    else
    {
        version = "PPSSPP " + modules.First().FileVersionInfo.FileVersion;
    }

    vars.Memory = null;
}

update
{
    if (string.IsNullOrEmpty(version)) 
    {
        return false;
    }

    if (version.StartsWith("DuckStation")) 
    {
        if (vars.Memory == null || current.gameId != old.gameId)
        {
            if (current.gameId == "SLUS_011.40")
            {
                vars.Memory = new MemoryWatcherList();
                vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x9C808)) { Name = "Area" });
                vars.Memory.Add(new MemoryWatcher<int>(new IntPtr(current.baseAddress + 0x9C818)) { Name = "IGT" });
                vars.Memory.Add(new MemoryWatcher<int>(new IntPtr(current.baseAddress + 0x9C810)) { Name = "Final IGT" });
                vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x9C816)) { Name = "Game Complete" });
                vars.Memory.Add(new MemoryWatcher<byte>(new IntPtr(current.baseAddress + 0x985D1)) { Name = "Refractors" });
            }
            else if (current.gameId == "SLPS_027.11")
            {
                vars.Memory = new MemoryWatcherList();
                vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x9CAB0)) { Name = "Area" });
                vars.Memory.Add(new MemoryWatcher<int>(new IntPtr(current.baseAddress + 0x9CAC0)) { Name = "IGT" });
                vars.Memory.Add(new MemoryWatcher<int>(new IntPtr(current.baseAddress + 0x9CAB8)) { Name = "Final IGT" });
                vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x9CABE)) { Name = "Game Complete" });
                vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x98879)) { Name = "Refractors" });
            }

            vars.Memory.UpdateAll(game);
        }
    }
    else
    {
        if (vars.Memory == null)
        {
            vars.Memory = new MemoryWatcherList();
            vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x8DADD0C)) { Name = "Area" });
            vars.Memory.Add(new MemoryWatcher<int>(new IntPtr(current.baseAddress + 0x8DADD1C)) { Name = "IGT" });
            vars.Memory.Add(new MemoryWatcher<int>(new IntPtr(current.baseAddress + 0x8DADD14)) { Name = "Final IGT" });
            vars.Memory.Add(new MemoryWatcher<short>(new IntPtr(current.baseAddress + 0x8DADD1A)) { Name = "Game Complete" });
            vars.Memory.Add(new MemoryWatcher<byte>(new IntPtr(current.baseAddress + 0x9057EC9)) { Name = "Refractors" });

            vars.Memory.UpdateAll(game);
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

    if (!vars.IGTStopped)
    {
        vars.IGTStopped = vars.Memory["Game Complete"].Current > vars.Memory["Game Complete"].Old;
    }

    return true;
}

isLoading
{
    return true;
}

gameTime
{
    if (!vars.IGTStarted)
    {
        return TimeSpan.FromSeconds(0);
    }

    if (vars.IGTStopped) // Game has ended, show final IGT
    {
        return TimeSpan.FromSeconds(vars.Memory["Final IGT"].Current / 60.0D);
    }

    return TimeSpan.FromSeconds(vars.Memory["IGT"].Current / 60.0D);
}

start
{
    if (settings["igt_timer_start"])
    {
        return vars.Memory["Area"].Current == 0x0039 && vars.Memory["IGT"].Current > vars.Memory["IGT"].Old && vars.Memory["IGT"].Old == 0;
    }
    
    return vars.Memory["Area"].Current == 0x0039 && vars.Memory["Area"].Current != vars.Memory["Area"].Old;
}


split
{
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