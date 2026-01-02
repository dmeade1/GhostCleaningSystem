# Reference Images

This directory is for storing quality standard photos that show cleaning crews what "done" looks like for specific tasks.

## Setup in Supabase

1. Go to your Supabase project dashboard
2. Navigate to Storage
3. Create a new bucket called `reference-images`
4. Set it to **public** access
5. Upload your reference photos

## Naming Convention

Use descriptive names that match your tasks:

```
main-deck-clean.jpg
galley-countertop-standard.jpg
bathroom-mirror-finish.jpg
engine-room-organized.jpg
```

## Linking to Tasks

When creating tasks in the database, add the reference image URL:

```sql
UPDATE tasks 
SET reference_image_url = 'https://your-project.supabase.co/storage/v1/object/public/reference-images/main-deck-clean.jpg'
WHERE title = 'Clean Main Deck';
```

## Image Guidelines

- **Format**: JPG or PNG
- **Size**: Max 2MB per image
- **Resolution**: 1920x1080 or similar
- **Quality**: Clear, well-lit photos showing the completed standard
- **Angle**: Show the area from the crew's perspective

## Example Structure

```
reference-images/
├── main-deck/
│   ├── deck-sweep.jpg
│   ├── railings-clean.jpg
│   └── windows-spotless.jpg
├── salon/
│   ├── furniture-arranged.jpg
│   └── floor-polished.jpg
└── galley/
    ├── counters-sanitized.jpg
    └── appliances-clean.jpg
```

## Tips

- Take photos in good lighting
- Show the entire area that needs to be cleaned
- Include close-ups for detail work
- Update photos seasonally if needed
- Get supervisor approval before uploading

---

These reference images help maintain consistent quality standards across all cleaning jobs!
