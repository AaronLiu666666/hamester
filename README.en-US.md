

# Hamster

<div align=center><img src="https://github.com/AaronLiu666666/hamester/blob/master/android/app/src/main/res/mipmap-hdpi/hamester_logo.png" width="100px" height="100px"></div>

**Hamster** is an Android application for playing and managing local video media files. The name "Hamster" implies collecting and managing videos just like a hamster stores food. Key features include video playback, tag management, and marking highlight moments.

## Main Features/Modules

### Settings

- **Media Scan Directory Settings**: Users can configure the directories the app scans for media files.

### Media Library List

- **Display Media Files**: Shows all video files in the scanned media directories.
- **Play Video**: Tapping a video file navigates to the video playback page.
- **Video Details**: Long-pressing a video file opens the video details page, displaying detailed information (video name, duration, file size, tags, and highlight moments).

### Video Details

- **Video Information**: Displays detailed video info, including name, duration, file size, tags, and highlight moments.
- **Tags and Highlights**: Tapping a tag navigates to the tag details page. Tapping a highlight moment navigates directly to the playback page.
- **Edit Video Information**: Allows setting an alias and notes for the video file, and deleting the video (which also deletes all its associated highlight moments).

### Video Playback Page

- **Play Video**: The center area plays the video.
- **Video List Scrollbar**: A horizontal scrollbar at the bottom displays a list of videos, allowing scrolling to load and switch between videos for playback.
- **Highlight Moments Scrollbar**: A horizontal scrollbar at the top displays the highlight moments for the current video, allowing scrolling to load and switch playback.
- **Playback Settings**: Supports setting playback speed and fullscreen mode.
- **Capture Highlight Moments**: A camera-shaped button on the right-middle captures the current video frame to create a highlight moment. Users can add tags and descriptions to the highlight. Non-existent tags are automatically created, and the highlight screenshot is used as the tag's cover image.

### Tag List

- **Display All Tags**: Tapping a tag plays the first highlight moment from the first associated video. The scrollbar below the video shows a list of all highlight moments tagged with this tag, while the top shows the highlight moments list for the currently playing video.
- **Tag Details**: Long-pressing a tag navigates to the tag details page.

### Tag Details Page

- **Tag Name**: The tag name is displayed at the top, separated by slashes ("/"). Tapping a specific level shows the tag details for that level.
- **Tag Details**: Contains three tabs:
    - **Highlight Moments List**: Displays all highlight moments with this tag. Tap to play, long-press for highlight details.
    - **Video List**: Displays all videos with this tag. Tap to play, long-press for video details.
    - **Edit Tag**: Edit tag name and info, change the tag cover image, and delete the tag (which also deletes all highlight moments under this tag).

### Related Library (Highlight Moments) List

- **Display All Highlight Moments**: Each highlight moment uses its screenshot as a cover. Tapping navigates to the playback page, where the scroll list displays only that single highlight moment.
- **Highlight Moment Details**: Long-pressing navigates to the details page to edit the description or delete the highlight moment.

### Search Functionality

- **Media Library**: Fuzzy search matching for videos based on video filename, video alias, video tag name, and highlight moment description.
- **Tag Library**: Fuzzy search based on tag names.
- **Related Library**: Fuzzy search based on tag names and highlight moment descriptions.

### Pagination Module

- **Pagination Feature**: Pagination controls at the bottom of the Media, Tag, and Related Library lists allow navigating to the top/bottom of the list, previous page, and next page.

### Waterfall Flow Feature
- **Waterfall Flow**: Long-pressing the Media Library, Tag Library, or Related Library in the bottom navigation bar enters this mode, which randomly displays media cards, tag cards, and related (highlight moment) cards in a waterfall layout. Tapping a card navigates to the playback interface, while long-pressing navigates to details.

## Installation and Usage


## Bugs & Optimizations & New Features

### Bugs

- [ ] Missing two horizontal switching lists in fullscreen mode (media highlight moments horizontal scrollbar, media list horizontal scrollbar). Investigate whether to avoid chewie's fullscreen, as chewie's forced initialization in fullscreen is somewhat uncontrollable
- [x] When switching to fullscreen and returning to portrait mode, playback restarts from seekto or the beginning, failing to retain the pre-switch position
- [ ] Nested navigation issue: e.g., entering video info from tag info, then selecting another tag still leads back to the original tag (caused by getx not passing tagId)
- [x] Incorrect screenshot capture for highlight moments in long videos. The thumbnail plugin fails to capture at the exact seekTo position when seekto is too large (switched to implementing with ffmpeg)
- [x] ffmpeg highlight moment screenshot failure (video filename in the command was not wrapped in quotes)
- [x] Screen turns off after playing for a while (using wakelock plugin to force screen on during playback)
- [x] On the playback interface, the volume and time indicators are too close to the drag slider
- [x] List cards: Filenames and other names are too long, causing images to display too small or not at all (changed to display only one line of text, with full text shown in a tooltip on long-press)

### Optimizations

- [ ] On the video playback page, rapidly tapping the highlight moment button repeatedly opens the highlight moment (association) creation dialog
- [ ] Change the tag input field during highlight moment creation to a searchable dropdown
- [ ] Auto-merge duplicate tag names when editing, with a confirmation dialog (deletes the original tag and reassigns its associations to the duplicate tag)
- [ ] Tag list: Search with `LIKE %name%` when entering details
- [ ] 10-second fast-forward/rewind on the video playback page
- [ ] List displays current page, total pages, total items, page number jumping, etc.
- [ ] Video duration initialization, video duration sorting feature (and implementation of custom sorting for other lists)
- [ ] When playing from a non-start position (seekTo != 0), a single frame of the intro flashes. Optimize to wait until the seek position is reached before playing, avoiding the intro flash
- [ ] Optimize local video playback or seekTo loading duration
- [ ] Animations, playback state recording & restoration: On the video playback page, creating a highlight moment should pause instead of toggling state. Record the state before entering the creation page and restore it upon return. Same applies to waterfall flow animations
- [ ] Graph display issue when switching play/pause buttons during waterfall flow animation
- [ ] Next page/last page sometimes jumps to the end of the current page
- [x] Display creation time in highlight moment details
- [x] Long-press on playback page to enter details (association details/media details)
- [ ] Database design optimization: Highlight Moment - Tag should be a one-to-many relationship, not one-to-one
- [ ] Provide editing functionality in highlight moment details, allowing adding/removing tags during editing
- [ ] During initial traversal scanning, clear data for deleted files or files not in the scan path (clear media and highlight moments)
- [ ] Rename homepage bottom navigation: Tags, Media, Highlights
- [ ] Merge functionality for adjacent (e.g., 3s) highlight moments of the same media: group adjacent moments and allow merging into one
- [ ] When adding a highlight moment, prompt for adjacent (e.g., 3s) moments in the dialog, allowing the user to merge into an existing moment instead of creating a new one

### New Features 

- [ ] Reporting & statistics features: e.g., day with the most tags, video with the most tags, etc.
- [ ] Highlight Segments: Add a new button on the video playback page. Press once to record start moment, press again to record end moment, then a dialog pops up to tag the time segment (highlight segment)
- [ ] Highlight Segments: One-click export to compile highlight segments into a video
- [ ] Video Playback: Select BGM
- [ ] Highlight Segment Carousel (play highlight segments sequentially; when encountering a highlight moment, play for n seconds after the moment)
- [ ] Custom tag details implementation: Allow writing custom pages for specific tags to achieve more diverse detail pages
- [x] Waterfall flow
- [x] Video playback page: Highlight moments scrollbar, media list scrollbar (displays different media lists depending on entry point)
- [ ] Association topology graph (like Obsidian's graph view)
- [x] Lists: Previous page, next page, first page, last page
- [ ] iOS Photos-like management: Display images/videos at the top, with tags directly below for categorization. Four types of tag associations: Image-Tag, Video-Tag, Moment-Tag, Segment-Tag
- [ ] Cover settings feature: Allow adding/setting cover images for videos (can directly select from highlight moment screenshots)
- [ ] Cover display settings: Show first frame, show highlight moment screenshot
- [ ] Browsing history feature: History table, add browsing history to the side drawer
- [ ] Dark mode

## Third-Party Dependencies

### State Management: GetX
[get | Flutter package (pub.dev)](https://pub.dev/packages/get)

### Database: sqlite

### Database ORM: floor

### Video Thumbnails: video_thumbnail

### Highlight Moment Screenshots: ffmpeg_kit_flutter

### Video Player: chewie

### Permission Handling: permission_handler
