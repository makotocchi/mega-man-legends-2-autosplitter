// MML2 Emulator Auto Splitter
// Made by apel
// Based on the GTA Liberty City Stories Autosplitter by NABN00B
// https://github.com/NABN00B/LiveSplit.Autosplitters/blob/master/LiveSplit.PPSSPP.GTA-LCS.asl
// And also bmn's MGS1 Autosplitter
// https://github.com/bmn/livesplit_asl_mgs1/blob/master/MetalGearSolid.asl

state("duckstation-qt-x64-ReleaseLTCG") {} // DuckStation
state("duckstation-nogui-x64-ReleaseLTCG") {} // DuckStation
state("PPSSPPWindows64"){} // PPSSPP

startup
{
    version = "unknown";

    vars.OffsetToPSPUserMemory = 0x0;
    vars.PSXBaseAddress = 0x0;
    vars.OldPSXBaseAddress = 0x0;
    vars.IGTStarted = false;
    vars.GameCompleteCount = 0;
    vars.TrainBattleCounter = 0;
    vars.BolaBattle1Done = false;

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

    settings.Add("nino_invasion", true, "Nino Invasion");
    settings.SetToolTip("nino_invasion", "Split when you complete the Nino Invasion");

    settings.Add("glyde_base", true, "Glyde's Base");
    settings.SetToolTip("glyde_base", "Split when you complete Glyde's Base");

    settings.Add("nino_ruins", true, "Nino Ruins");
    settings.SetToolTip("nino_ruins", "Split when you complete Nino Ruins");

    settings.Add("kimotama_city", true, "Kimotama City");
    settings.SetToolTip("kimotama_city", "Split when you complete Kimotama City");

    settings.Add("saul_kada_ruins", true, "Saul Kada Ruins");
    settings.SetToolTip("saul_kada_ruins", "Split when you complete Saul Kada Ruins");

    settings.Add("train_battle", true, "Train Battle");
    settings.SetToolTip("train_battle", "Split when you complete the Train Battle");

    settings.Add("calinca_ruins", true, "Calinca Ruins");
    settings.SetToolTip("calinca_ruins", "Split when you complete Calinca Ruins");

    settings.Add("elysium", true, "Elysium");
    settings.SetToolTip("elysium", "Split when you complete Elysium");

    settings.Add("boss_rush", true, "Boss Rush");
    settings.SetToolTip("boss_rush", "Split when you complete the Boss Rush");

    settings.Add("igt_screen", true, "IGT Screen");
    settings.SetToolTip("igt_screen", "Split when you reach the final IGT Screen");
    
    vars.ResetAllVars = (Action)(() => {
        vars.OffsetToPSPUserMemory = 0x0;
        vars.PSXBaseAddress = 0x0;
        vars.OldPSXBaseAddress = 0x0;

        vars.ResetGameVars();
    });

    vars.ResetGameVars = (Action)(() => {
        vars.IGTStarted = false;
        vars.GameCompleteCount = 0;
        vars.TrainBattleCounter = 0;
        vars.BolaBattle1Done = false;
    });

    vars.TimerOnStart = (EventHandler)((sender, e) => {
        if (vars.MemoryWatchers != null)
        {
            vars.GameCompleteCount = vars.MemoryWatchers["Game Complete"].Current;
            vars.IGTStarted = vars.MemoryWatchers["Area"].Current != 0x0039 || 
                (vars.MemoryWatchers["Area"].Current == 0x0039 && vars.MemoryWatchers["IGT"].Current > vars.MemoryWatchers["IGT"].Old && vars.MemoryWatchers["IGT"].Old == 0);
        }
    });

    vars.TimerOnReset = (LiveSplit.Model.Input.EventHandlerT<TimerPhase>)((sender, e) => {
        vars.ResetGameVars();
    });

    timer.OnStart += vars.TimerOnStart;
    timer.OnReset += vars.TimerOnReset;
    
    vars.ScanForGameInDuckStation = (Func<Process, bool>)((duckstation) => 
    {
        if (vars.PSXBaseAddress == 0x0) 
        {
            foreach (var page in duckstation.MemoryPages(true)) 
            {
                if (page.RegionSize == (UIntPtr)0x200000 && page.Type == MemPageType.MEM_MAPPED)
                {
                    vars.PSXBaseAddress = (long)page.BaseAddress;
                    break;
                }
            }
        }

        if (vars.PSXBaseAddress != vars.OldPSXBaseAddress)
        {
            print("PSX MainRAM: " + vars.PSXBaseAddress.ToString("X"));

            vars.MemoryWatchers = new MemoryWatcherList();
            vars.MemoryWatchers.Add(new MemoryWatcher<short>(new IntPtr(vars.PSXBaseAddress + 0x9CAB0L)) { Name = "Area" });
            vars.MemoryWatchers.Add(new MemoryWatcher<int>(new IntPtr(vars.PSXBaseAddress + 0x9CAC0L)) { Name = "IGT" });
            vars.MemoryWatchers.Add(new MemoryWatcher<int>(new IntPtr(vars.PSXBaseAddress + 0x9CAB8L)) { Name = "Final IGT" });
            vars.MemoryWatchers.Add(new MemoryWatcher<short>(new IntPtr(vars.PSXBaseAddress + 0x9CABEL)) { Name = "Game Complete" });

            vars.OldPSXBaseAddress = vars.PSXBaseAddress;
        }
      
        return vars.PSXBaseAddress != 0x0;
    });
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
        version = "PPSSPP";

        var page = modules.First();
        var scanner = new SignatureScanner(game, page.BaseAddress, page.ModuleMemorySize);
        IntPtr ptr = scanner.Scan(new SigScanTarget(22, "41 B9 ?? 05 00 00 48 89 44 24 20 8D 4A FC E8 ?? ?? ?? FF 48 8B 0D ?? ?? ?? 00 48 03 CB"));

        if (ptr != IntPtr.Zero)
        {
            vars.OffsetToPSPUserMemory = (int) ((long)ptr - (long)page.BaseAddress + game.ReadValue<int>(ptr) + 0x4);
            version += " " + modules.First().FileVersionInfo.FileVersion;
        }
        else
        {
            // Switch to manual version detection if the signature scan fails.
            switch (modules.First().FileVersionInfo.FileVersion)
            {
                // Add new versions to the top.
                case "v1.10.3" : version += " v1.10.3"; vars.OffsetToPSPUserMemory = 0xC54CB0; break;
                case "v1.10.2" : version += " v1.10.2"; vars.OffsetToPSPUserMemory = 0xC53CB0; break;
                case "v1.10.1" : version += " v1.10.1"; vars.OffsetToPSPUserMemory = 0xC53B00; break;
                case "v1.10"   : version += " v1.10"  ; vars.OffsetToPSPUserMemory = 0xC53AC0; break;
                case "v1.9.3"  : version += " v1.9.3" ; vars.OffsetToPSPUserMemory = 0xD8C010; break;
                case "v1.9"    : version += " v1.9"   ; vars.OffsetToPSPUserMemory = 0xD8AF70; break;
                case "v1.8.0"  : version += " v1.8.0" ; vars.OffsetToPSPUserMemory = 0xDC8FB0; break;
                case "v1.7.4"  : version += " v1.7.4" ; vars.OffsetToPSPUserMemory = 0xD91250; break;
                case "v1.7.1"  : version += " v1.7.1" ; vars.OffsetToPSPUserMemory = 0xD91250; break;
                case "v1.7"    : version += " v1.7"   ; vars.OffsetToPSPUserMemory = 0xD90250; break;
                default        : version = "unknown"; vars.OffsetToPSPUserMemory = 0x0     ; break;
            }
        }

        if (version != "unknown")
        {
            print("PSP User Memory Offset: " + vars.OffsetToPSPUserMemory.ToString("X"));

            vars.MemoryWatchers = new MemoryWatcherList();
            vars.MemoryWatchers.Add(new MemoryWatcher<short>(new DeepPointer(vars.OffsetToPSPUserMemory, 0x08800000 + 0x5ADD0C)) { Name = "Area" });
            vars.MemoryWatchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.OffsetToPSPUserMemory, 0x08800000 + 0x5ADD1C)) { Name = "IGT" });
            vars.MemoryWatchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.OffsetToPSPUserMemory, 0x08800000 + 0x5ADD14)) { Name = "Final IGT" });
            vars.MemoryWatchers.Add(new MemoryWatcher<short>(new DeepPointer(vars.OffsetToPSPUserMemory, 0x08800000 + 0x5ADD1A)) { Name = "Game Complete" });
        }
    }
    
}

exit
{
    version = "unknown";
    vars.ResetAllVars();
}

shutdown
{
    timer.OnStart -= vars.TimerOnStart;
}

update
{
    if (version != null && game != null && ((version.Contains("DuckStation") && vars.ScanForGameInDuckStation(game)) || version.Contains("PPSSPP")))
    {
        vars.MemoryWatchers.UpdateAll(game);

        if (!vars.IGTStarted)
        {
            vars.IGTStarted = vars.MemoryWatchers["Area"].Current != 0x0039 || 
                (vars.MemoryWatchers["Area"].Current == 0x0039 && vars.MemoryWatchers["IGT"].Current > vars.MemoryWatchers["IGT"].Old && vars.MemoryWatchers["IGT"].Old == 0);
        }

        return true;
    }

    return false;
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

    if (vars.MemoryWatchers["Game Complete"].Current > vars.GameCompleteCount) // Game has ended, show final IGT
    {
        return TimeSpan.FromSeconds(vars.MemoryWatchers["Final IGT"].Current / 60.0D);
    }

    return TimeSpan.FromSeconds(vars.MemoryWatchers["IGT"].Current / 60.0D);
}

start
{
    if (settings["igt_timer_start"])
    {
        return vars.MemoryWatchers["Area"].Current == 0x0039 && vars.MemoryWatchers["IGT"].Current > vars.MemoryWatchers["IGT"].Old && vars.MemoryWatchers["IGT"].Old == 0;
    }
    
    return vars.MemoryWatchers["Area"].Current == 0x0039 && vars.MemoryWatchers["Area"].Current != vars.MemoryWatchers["Area"].Old;
}

split
{
    if (settings["abandoned_mines"] && vars.MemoryWatchers["Area"].Old == 0x0B0F && vars.MemoryWatchers["Area"].Current == 0x0247) // complete abandoned mine
    {
        return true;
    }

    if (settings["forbidden_island"] && vars.MemoryWatchers["Area"].Old == 0x021D && vars.MemoryWatchers["Area"].Current == 0x001C) // complete forbidden islands
    {
        return true;
    }

    if (settings["crab_battle"] && vars.MemoryWatchers["Area"].Old == 0x0625 && vars.MemoryWatchers["Area"].Current == 0x0025) // beat crab
    {
        return true;
    }

    // if (settings["bola_battle_1"] && !vars.BolaBattle1Done && vars.MemoryWatchers["Area"].Old == 0x0113 && vars.MemoryWatchers["Area"].Current == 0x0213) // beat bola 1
    // {
    //     vars.BolaBattle1Done = true;
    //     return true;
    // }

    // if (settings["bola_battle_2"] && vars.MemoryWatchers["Area"].Old == 0x0512 && vars.MemoryWatchers["Area"].Current == 0x0412) // beat bola 2
    // {
    //     return true;
    // }

    if (settings["manda_ruins"] && vars.MemoryWatchers["Area"].Old == 0x0414 && vars.MemoryWatchers["Area"].Current == 0x0124) // beat manda ruins
    {
        return true;
    }

    if (settings["nino_invasion"] && vars.MemoryWatchers["Area"].Old == 0x0018 && vars.MemoryWatchers["Area"].Current == 0x0019) // beat nino invasion
    {
        return true;
    }

    if (settings["glyde_base"] && vars.MemoryWatchers["Area"].Old == 0x0230 && vars.MemoryWatchers["Area"].Current == 0x001F) // complete glyde's base
    {
        return true;
    }

    if (settings["nino_ruins"] && vars.MemoryWatchers["Area"].Old == 0x0035 && vars.MemoryWatchers["Area"].Current == 0x0119) // complete nino ruins
    {
        return true;
    }

    if (settings["kimotama_city"] && vars.MemoryWatchers["Area"].Old == 0x023C && vars.MemoryWatchers["Area"].Current == 0x0026) // complete kimotama city
    {
        return true;
    }

    if (settings["saul_kada_ruins"] && vars.MemoryWatchers["Area"].Old == 0x0028 && vars.MemoryWatchers["Area"].Current == 0x023C) // complete saul kada ruins
    {
        return true;
    }

    if (settings["train_battle"] && vars.MemoryWatchers["Area"].Old == 0x020E && vars.MemoryWatchers["Area"].Current == 0x0153) // beat train
    {
        vars.TrainBattleCounter++;
        return vars.TrainBattleCounter >= 2; // the train battle has two phases, it should only split after the second one
    }

    if (settings["calinca_ruins"] && vars.MemoryWatchers["Area"].Old == 0x072F && vars.MemoryWatchers["Area"].Current == 0x010B) // complete calinca ruins
    {
        return true;
    }

    if (settings["elysium"] && vars.MemoryWatchers["Area"].Old == 0x0056 && vars.MemoryWatchers["Area"].Current == 0x0043) // complete elysium
    {
        return true;
    }

    if (settings["boss_rush"] && vars.MemoryWatchers["Area"].Old == 0x0545 && vars.MemoryWatchers["Area"].Current == 0x004C) // beat boss rush
    {
        return true;
    }

    if (settings["igt_screen"] && vars.MemoryWatchers["Game Complete"].Old != vars.MemoryWatchers["Game Complete"].Current && vars.MemoryWatchers["Game Complete"].Current > vars.GameCompleteCount) // IGT stops
    {
        return true;
    }

    return false;
}